function may_color() {
	# 1. Check for CI/CD environments (usually no colors or limited)
	if [[ -n "${CI:-}" || -n "${CONTINUOUS_INTEGRATION:-}" ]]; then
		# Some CI systems support colors, check specific ones
		case "${CI_SYSTEM:-}" in
			GitHub-Actions|gitlab|jenkins)
				# Most modern CI supports ANSI colors
				[[ -t 1 ]] && return 0 || return 1
				;;
			*)
				# Unknown CI, be conservative
				return 1
				;;
		esac
	fi
	
	# 2. Check for specific CI environment variables
	if [[ -n "${GITHUB_ACTIONS:-}" || -n "${GITLAB_CI:-}" || -n "${JENKINS_URL:-}" || -n "${TEAMCITY_VERSION:-}" ]]; then
		# Most modern CI supports colors when output is a TTY
		[[ -t 1 ]] && return 0 || return 1
	fi
	
	# 3. Check for NO_COLOR environment variable (standard for disabling colors)
	if [[ -n "${NO_COLOR:-}" ]]; then
		return 0  # Respect NO_COLOR but allow our functions to handle it
	fi
	
	# 4. Check for modern terminal programs
	local term_program="${TERM_PROGRAM:-}"
	local term="${TERM:-}"
	
	# Modern terminal emulators
	case "$term_program" in
		iTerm.app|vscode|warp|wezterm|hyper|alacritty|kitty)
			return 0
			;;
	esac
	
	# Terminal types
	case "$term" in
		# Modern and color-capable terminals
		*xterm*|*screen*|*tmux*|*rxvt*|*konsole*|*gnome*|*putty*|*cygwin*|*msys*|*mintty*)
			return 0
			;;
		# 256-color terminals
		*xterm-256color*|*screen-256color*|*tmux-256color*|*alacritty*|*kitty*)
			return 0
			;;
		# Color variants
		*color*|*256*|*direct*|*truecolor*)
			return 0
			;;
		# Dumb terminals (no color support)
		dumb|unknown|linux)
			return 1
			;;
		# Default: try to detect if we're in a TTY
		*)
			# If we can't determine the terminal type, check if we're interactive
			[[ -t 1 ]] && return 0 || return 1
			;;
	esac
}

# DEPRECATED: Use text_yellow(), text_red(), text_green(), text_blue() instead
# These functions are kept for backward compatibility but will be removed in future versions
function yellow() { printf "%s" "$(text_yellow "$@")"; }
function red()    { printf "%s" "$(text_red "$@")";    }
function green()  { printf "%s" "$(text_green "$@")";  }
function blue()   { printf "%s" "$(text_blue "$@")";   }



function echoc() {
	local color=$(echo "$1"|tr '[:upper:]' '[:lower:]')
	local title=$2
	shift 2
	local message=$@
	# If QUIET/silent mode is enabled, suppress non-error output
	if [[ "${QUIET:-}" == "true" || "${QUIET:-}" == "1" ]]; then
		# Only allow printing errors (red/danger)
		if [[ "$color" != "red" && "$color" != "danger" ]]; then
			return 0
		fi
	fi
	{
		if $(may_color); then
			case "$color" in
			red|danger)
				printf "%s %s" "$(text_danger "$(fw_bold "$title")")" "$message"
				;;
			green|success)
				printf "%s %s" "$(text_success "$(fw_bold "$title")")" "$message"
				;;
			yellow|warning)
				printf "%s %s" "$(text_warning "$(fw_bold "$title")")" "$message"
				;;
			blue|info)
				printf "%s %s" "$(text_info "$(fw_bold "$title")")" "$message"
				;;
			*)
				echo -n "$title $message"
				;;
			esac
		else
			echo -n "$title $message"
		fi
		echo
	} >&2
}

function is_quiet() { [[ "${QUIET:-}" == "true" || "${QUIET:-}" == "1" ]] }

function info()    { is_quiet || printf "%s %s\n" "$(text_info "$(fw_bold "[INFO]")")" "$*" >&2;   	    }
function debug()   { is_quiet || printf "%s %s\n" "$(text_secondary "$(fw_bold "[DEBUG]")")" "$*" >&2;  }
function error()   { is_quiet || printf "%s %s\n" "$(text_danger "$(fw_bold "[ERROR]")")" "$*" >&2;     }
function warn()    { is_quiet || printf "%s %s\n" "$(text_warning "$(fw_bold "[WARN]")")" "$*" >&2;     }
function success() { is_quiet || printf "%s %s\n" "$(text_success "$(fw_bold "[SUCCESS]")")" "$*" >&2;  }

function has_tty_available() {
	# 1. Check for CI/CD environments first - assume TTY is available for confirmations
	if [[ -n "${CI:-}" || -n "${CONTINUOUS_INTEGRATION:-}" || -n "${GITHUB_ACTIONS:-}" || -n "${GITLAB_CI:-}" || -n "${JENKINS_URL:-}" || -n "${TEAMCITY_VERSION:-}" ]]; then
		# In CI/CD, we assume TTY is available for automated confirmations
		return 0
	fi
	
	# 2. Check for actual TTY availability in regular environments
	if [[ -t 0 || -t 1 || -t 2 ]]; then
		return 0
	fi
	
	# 3. Check if /dev/tty is accessible
	if [[ -r /dev/tty && -w /dev/tty ]]; then
		return 0
	fi
	
	# 4. Check for common non-interactive environments
	if [[ "${TERM:-}" == "dumb" || "${TERM:-}" == "unknown" ]]; then
		return 1
	fi
	
	# 5. Default to false for regular non-TTY environments
	return 1
}

function confirm_action() {
	local prompt="${1:-Are you sure? [y/N]: }"
	local default_response="n"
	local answer=""

	if [[ "${QUIET:-}" == "true" || "${QUIET:-}" == "1" ]]; then
		error "❌ Confirmation required but QUIET mode is enabled."
		return 1
	fi

	if ! has_tty_available; then
		error "❌ Confirmation required but no interactive terminal is available."
		return 1
	fi

	local read_fd=""
	local need_close_fd="false"

	if [[ -t 0 ]]; then
		read_fd="0"
	elif [[ -r /dev/tty ]]; then
		if exec {read_fd}<>/dev/tty; then
			need_close_fd="true"
		else
			read_fd=""
		fi
	fi

	if [[ -z "${read_fd}" ]]; then
		error "❌ Confirmation required but could not access a terminal."
		return 1
	fi

	local prompt_fd=""
	if [[ -t 2 ]]; then
		prompt_fd="2"
	elif [[ -t 1 ]]; then
		prompt_fd="1"
	else
		prompt_fd="${read_fd}"
	fi

	while true; do
		printf '%s' "${prompt}" >&${prompt_fd}
		if ! IFS= read -r -u "${read_fd}" answer; then
			answer=""
		fi

		if [[ -z "${answer}" ]]; then
			answer="${default_response}"
		fi

		case "${answer}" in
			y|Y|yes|YES)
				if [[ "${need_close_fd}" == "true" ]]; then
					exec {read_fd}>&-
				fi
				return 0
				;;
			n|N|no|NO)
				if [[ "${need_close_fd}" == "true" ]]; then
					exec {read_fd}>&-
				fi
				return 1
				;;
			*)
				warn "⚠️ Please answer 'y' or 'n'."
				;;
		esac
	done
}

function split_title() {
	local max_length="80"
	local text="$@"

	while [[ ${#text} -gt $max_length ]]; do
		# Cut the text at maximum allowed length
		echo "*** ${text:0:$max_length} ***"
		# Rest of the text
		text="${text:$max_length}"
	done
	# Show the rest that doesn't exceed the limit
	echo "*** $text ***" >&2
}

# DEPRECATED: Use title() instead for better Bootstrap-style formatting
# This function is kept for backward compatibility but will be removed in future versions
function printtitle() {
	local title="$@"
	printf "\n" >&2
	printf "%s\n" "$(text_primary "********************************************")" >&2
	printf "%s\n" "$(text_primary "*** $(fw_bold "$title") ***")" >&2
	printf "%s\n" "$(text_primary "********************************************")" >&2
	printf "\n" >&2
}

# Ensure given commands exist in PATH; print friendly errors and return non-zero if any missing
# Usage: ensure_commands glab jq yq
function ensure_commands() {
	local missing=()
	local cmd
	for cmd in "$@"; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			missing+=("$cmd")
		fi
	done
	if (( ${#missing[@]} > 0 )); then
		local m
		for m in "${missing[@]}"; do
			case "$m" in
				glab)
					error "❌ 'glab' CLI is required. Install it from https://gitlab.com/gitlab-org/cli and ensure it's on your PATH." ;;
				jq)
					error "❌ 'jq' is required. Install it from https://stedolan.github.io/jq/ or your package manager." ;;
				yq)
					error "❌ 'yq' is optional but required for YAML pretty printing unless Python+PyYAML fallback is configured. See https://mikefarah.gitbook.io/yq/" ;;
				*)
					error "❌ '$m' is required and was not found in PATH." ;;
			esac
		done
		return 1
	fi
	return 0
}

# If the user has a personal token in GITLAB_TOKEN but GLAB_TOKEN isn't set, propagate it
function setup_gitlab_token() {
	if [[ -z "${GLAB_TOKEN:-}" && -n "${GITLAB_TOKEN:-}" ]]; then
		export GLAB_TOKEN="${GITLAB_TOKEN}"
		debug "Using GLAB_TOKEN from GITLAB_TOKEN environment variable."
	fi
}

# Combined helper to initialize environment for scripts.
# Pass the list of required commands for the script (e.g., glab jq)
function ensure_dependencies() {
	setup_gitlab_token
	ensure_commands "$@"
}


# Function to calculate yesterday's date in DDMMYYYY format (macOS and Linux compatible)
function get_yesterday_ddmmyyyy() {
  if [[ "$(uname)" == "Darwin" ]]; then
    date -v-1d +"%d%m%Y" 2>/dev/null || echo ""
  else
    date -d "yesterday" +"%d%m%Y" 2>/dev/null || echo ""
  fi
}

# Function to calculate date N days ago in ISO 8601 UTC format (macOS and Linux compatible)
function get_days_ago_iso8601() {
  local days="${1:-7}"
  if [[ "$(uname)" == "Darwin" ]]; then
    date -v-${days}d -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-${days}d +"%Y-%m-%d" 2>/dev/null || echo ""
  else
    date -d "${days} days ago" -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -d "${days} days ago" -u +"%Y-%m-%d" 2>/dev/null || echo ""
  fi
}

# Function to calculate date in N days in ISO 8601 UTC format (macOS and Linux compatible)
function get_days_ahead_iso8601() {
  local days="${1:-1}"
  if [[ "$(uname)" == "Darwin" ]]; then
    date -v+${days}d -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v+${days}d +"%Y-%m-%d" 2>/dev/null || echo ""
  else
    date -d "${days} days" -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -d "${days} days" -u +"%Y-%m-%d" 2>/dev/null || echo ""
  fi
}

# ==========================================
# 🎨 UI FRAMEWORK (Estilo Bootstrap)
# ==========================================

# 1. MODIFICADORES EN LÍNEA
# Estilos Tipográficos (Componibles).
fw_bold()      { printf "\033[1m%s\033[22m" "$1"; }
fw_dim()       { printf "\033[2m%s\033[22m" "$1"; }
fw_italic()    { printf "\033[3m%s\033[23m" "$1"; }
fw_underline() { printf "\033[4m%s\033[24m" "$1"; }
fw_reverse()   { printf "\033[7m%s\033[27m" "$1"; }
fw_strike()    { printf "\033[9m%s\033[29m" "$1"; }

# Colores de Texto (Foreground) usando paleta 256 colores para diseño más atractivo
text_primary()   { printf "\033[38;5;39m%s\033[39m" "$1"; }     # Azul
text_secondary() { printf "\033[38;5;244m%s\033[39m" "$1"; }    # Gris
text_success()   { printf "\033[38;5;40m%s\033[39m" "$1"; }     # Verde
text_danger()    { printf "\033[38;5;196m%s\033[39m" "$1"; }    # Rojo
text_warning()   { printf "\033[38;5;214m%s\033[39m" "$1"; }    # Amarillo/Naranja
text_info()      { printf "\033[38;5;45m%s\033[39m" "$1"; }     # Cyan
text_light()     { printf "\033[38;5;253m%s\033[39m" "$1"; }    # Blanco apagado
text_dark()      { printf "\033[38;5;236m%s\033[39m" "$1"; }    # Gris muy oscuro
text_muted()     { printf "\033[38;5;240m%s\033[39m" "$1"; }    # Texto tenue (DEPRECATED in Bootstrap 5.3)

# Bootstrap 5.3 Body colors
text_body()           { printf "\033[38;5;250m%s\033[39m" "$1"; }  # Body text default
text_body_emphasis()  { printf "\033[1;38;5;250m%s\033[0m" "$1"; } # Body text emphasized
text_body_secondary() { printf "\033[38;5;245m%s\033[39m" "$1"; }  # Body text secondary
text_body_tertiary()  { printf "\033[38;5;243m%s\033[39m" "$1"; }  # Body text tertiary

# Bootstrap 5.3 Basic colors
text_black() { printf "\033[38;5;16m%s\033[39m" "$1"; }   # Negro puro
text_white() { printf "\033[38;5;231m%s\033[39m" "$1"; }  # Blanco puro

# Bootstrap 5.3 Emphasis colors (lighter variants)
text_primary_emphasis()   { printf "\033[38;5;111m%s\033[39m" "$1"; }  # Azul claro
text_secondary_emphasis() { printf "\033[38;5;248m%s\033[39m" "$1"; }  # Gris claro
text_success_emphasis()   { printf "\033[38;5;113m%s\033[39m" "$1"; }  # Verde claro
text_danger_emphasis()    { printf "\033[38;5;203m%s\033[39m" "$1"; }  # Rojo claro
text_warning_emphasis()   { printf "\033[38;5;221m%s\033[39m" "$1"; }  # Amarillo claro
text_info_emphasis()      { printf "\033[38;5;117m%s\033[39m" "$1"; }  # Cyan claro
text_light_emphasis()     { printf "\033[38;5;255m%s\033[39m" "$1"; }  # Blanco muy claro
text_dark_emphasis()      { printf "\033[38;5;238m%s\033[39m" "$1"; }  # Gris oscuro énfasis

# Bootstrap 5.3 Opacity utilities (simulated with lighter colors)
text_opacity_25() { printf "\033[38;5;254m%s\033[39m" "$1"; }  # 25% opacity (muy claro)
text_opacity_50() { printf "\033[38;5;248m%s\033[39m" "$1"; }  # 50% opacity (medio)
text_opacity_75() { printf "\033[38;5;240m%s\033[39m" "$1"; }  # 75% opacity (oscuro)
text_opacity_100() { printf "\033[38;5;232m%s\033[39m" "$1"; } # 100% opacity (completo)

# Bootstrap 5.3 Legacy opacity (deprecated but included for compatibility)
text_black_50() { printf "\033[38;5;242m%s\033[39m" "$1"; }  # Negro 50% (DEPRECATED)
text_white_50() { printf "\033[38;5;248m%s\033[39m" "$1"; }  # Blanco 50% (DEPRECATED)

# Bootstrap 5.3 Color Variants (100-900 scale)
# Blue variants
text_blue_100() { printf "\033[38;5;153m%s\033[39m" "$1"; }  # Lightest blue
text_blue_200() { printf "\033[38;5;117m%s\033[39m" "$1"; }  # Lighter blue
text_blue_300() { printf "\033[38;5;81m%s\033[39m" "$1"; }   # Light blue
text_blue_400() { printf "\033[38;5;45m%s\033[39m" "$1"; }   # Medium light blue
text_blue_500() { printf "\033[38;5;33m%s\033[39m" "$1"; }   # Base blue
text_blue_600() { printf "\033[38;5;27m%s\033[39m" "$1"; }   # Medium blue
text_blue_700() { printf "\033[38;5;26m%s\033[39m" "$1"; }   # Dark blue
text_blue_800() { printf "\033[38;5;25m%s\033[39m" "$1"; }   # Darker blue
text_blue_900() { printf "\033[38;5;24m%s\033[39m" "$1"; }   # Darkest blue

# Green variants
text_green_100() { printf "\033[38;5;194m%s\033[39m" "$1"; } # Lightest green
text_green_200() { printf "\033[38;5;158m%s\033[39m" "$1"; } # Lighter green
text_green_300() { printf "\033[38;5;122m%s\033[39m" "$1"; } # Light green
text_green_400() { printf "\033[38;5;86m%s\033[39m" "$1"; }  # Medium light green
text_green_500() { printf "\033[38;5;34m%s\033[39m" "$1"; }  # Base green
text_green_600() { printf "\033[38;5;28m%s\033[39m" "$1"; }  # Medium green
text_green_700() { printf "\033[38;5;22m%s\033[39m" "$1"; }  # Dark green
text_green_800() { printf "\033[38;5;2m%s\033[39m" "$1"; }   # Darker green
text_green_900() { printf "\033[38;5;1m%s\033[39m" "$1"; }   # Darkest green

# Red variants
text_red_100() { printf "\033[38;5;224m%s\033[39m" "$1"; }  # Lightest red
text_red_200() { printf "\033[38;5;203m%s\033[39m" "$1"; }  # Lighter red
text_red_300() { printf "\033[38;5;182m%s\033[39m" "$1"; }  # Light red
text_red_400() { printf "\033[38;5;161m%s\033[39m" "$1"; }  # Medium light red
text_red_500() { printf "\033[38;5;196m%s\033[39m" "$1"; }  # Base red
text_red_600() { printf "\033[38;5;124m%s\033[39m" "$1"; }  # Medium red
text_red_700() { printf "\033[38;5;88m%s\033[39m" "$1"; }   # Dark red
text_red_800() { printf "\033[38;5;52m%s\033[39m" "$1"; }   # Darker red
text_red_900() { printf "\033[38;5;1m%s\033[39m" "$1"; }    # Darkest red

# Yellow variants
text_yellow_100() { printf "\033[38;5;230m%s\033[39m" "$1"; } # Lightest yellow
text_yellow_200() { printf "\033[38;5;229m%s\033[39m" "$1"; } # Lighter yellow
text_yellow_300() { printf "\033[38;5;228m%s\033[39m" "$1"; } # Light yellow
text_yellow_400() { printf "\033[38;5;227m%s\033[39m" "$1"; } # Medium light yellow
text_yellow_500() { printf "\033[38;5;220m%s\033[39m" "$1"; } # Base yellow
text_yellow_600() { printf "\033[38;5;214m%s\033[39m" "$1"; } # Medium yellow
text_yellow_700() { printf "\033[38;5;178m%s\033[39m" "$1"; } # Dark yellow
text_yellow_800() { printf "\033[38;5;136m%s\033[39m" "$1"; } # Darker yellow
text_yellow_900() { printf "\033[38;5;94m%s\033[39m" "$1"; }  # Darkest yellow

# Gray variants
text_gray_100() { printf "\033[38;5;248m%s\033[39m" "$1"; }  # Lightest gray
text_gray_200() { printf "\033[38;5;247m%s\033[39m" "$1"; }  # Lighter gray
text_gray_300() { printf "\033[38;5;246m%s\033[39m" "$1"; }  # Light gray
text_gray_400() { printf "\033[38;5;245m%s\033[39m" "$1"; }  # Medium light gray
text_gray_500() { printf "\033[38;5;244m%s\033[39m" "$1"; }  # Base gray
text_gray_600() { printf "\033[38;5;243m%s\033[39m" "$1"; }  # Medium gray
text_gray_700() { printf "\033[38;5;242m%s\033[39m" "$1"; }  # Dark gray
text_gray_800() { printf "\033[38;5;241m%s\033[39m" "$1"; }  # Darker gray
text_gray_900() { printf "\033[38;5;240m%s\033[39m" "$1"; }  # Darkest gray

# Bootstrap 5.3 Subtle utilities
bg_primary_subtle()   { printf "\033[48;5;153m%s\033[49m" "$1"; }   # Primary background subtle
bg_secondary_subtle() { printf "\033[48;5;247m%s\033[49m" "$1"; }   # Secondary background subtle
bg_success_subtle()   { printf "\033[48;5;194m%s\033[49m" "$1"; }   # Success background subtle
bg_info_subtle()      { printf "\033[48;5;153m%s\033[49m" "$1"; }   # Info background subtle
bg_warning_subtle()   { printf "\033[48;5;230m%s\033[49m" "$1"; }   # Warning background subtle
bg_danger_subtle()    { printf "\033[48;5;224m%s\033[49m" "$1"; }   # Danger background subtle
bg_light_subtle()     { printf "\033[48;5;255m%s\033[49m" "$1"; }   # Light background subtle
bg_dark_subtle()      { printf "\033[48;5;245m%s\033[49m" "$1"; }   # Dark background subtle

border_primary_subtle()   { printf "\033[38;5;117m%s\033[39m" "$1"; }   # Primary border subtle
border_secondary_subtle() { printf "\033[38;5;246m%s\033[39m" "$1"; }   # Secondary border subtle
border_success_subtle()   { printf "\033[38;5;158m%s\033[39m" "$1"; }   # Success border subtle
border_info_subtle()      { printf "\033[38;5;117m%s\033[39m" "$1"; }   # Info border subtle
border_warning_subtle()   { printf "\033[38;5;229m%s\033[39m" "$1"; }   # Warning border subtle
border_danger_subtle()    { printf "\033[38;5;203m%s\033[39m" "$1"; }   # Danger border subtle
border_light_subtle()     { printf "\033[38;5;250m%s\033[39m" "$1"; }   # Light border subtle
border_dark_subtle()      { printf "\033[38;5;245m%s\033[39m" "$1"; }   # Dark border subtle

# Paleta completa extendida (Estilo Bootstrap: blue, indigo, purple, pink, red, orange, yellow, green, teal, cyan, white, gray)
text_blue()      { printf "\033[38;5;33m%s\033[39m" "$1"; }
text_indigo()    { printf "\033[38;5;99m%s\033[39m" "$1"; }
text_purple()    { printf "\033[38;5;135m%s\033[39m" "$1"; }
text_pink()      { printf "\033[38;5;162m%s\033[39m" "$1"; }
text_red()       { printf "\033[38;5;196m%s\033[39m" "$1"; }
text_orange()    { printf "\033[38;5;208m%s\033[39m" "$1"; }
text_yellow()    { printf "\033[38;5;220m%s\033[39m" "$1"; }
text_green()     { printf "\033[38;5;34m%s\033[39m" "$1"; }
text_teal()      { printf "\033[38;5;43m%s\033[39m" "$1"; }
text_cyan()      { printf "\033[38;5;51m%s\033[39m" "$1"; }
text_white()     { printf "\033[38;5;231m%s\033[39m" "$1"; }
text_gray()      { printf "\033[38;5;245m%s\033[39m" "$1"; }    # Texto tenue

# Colores de Fondo (Background)
bg_primary()   { printf "\033[48;5;39m%s\033[49m" "$1"; }
bg_secondary() { printf "\033[48;5;244m%s\033[49m" "$1"; }
bg_success()   { printf "\033[48;5;40m%s\033[49m" "$1"; }
bg_danger()    { printf "\033[48;5;196m%s\033[49m" "$1"; }
bg_warning()   { printf "\033[48;5;214m%s\033[49m" "$1"; }
bg_info()      { printf "\033[48;5;45m%s\033[49m" "$1"; }
bg_light()     { printf "\033[48;5;253m%s\033[49m" "$1"; }
bg_dark()      { printf "\033[48;5;236m%s\033[49m" "$1"; }

# Fondos de la paleta extendida
bg_blue()      { printf "\033[48;5;33m%s\033[49m" "$1"; }
bg_indigo()    { printf "\033[48;5;99m%s\033[49m" "$1"; }
bg_purple()    { printf "\033[48;5;135m%s\033[49m" "$1"; }
bg_pink()      { printf "\033[48;5;162m%s\033[49m" "$1"; }
bg_red()       { printf "\033[48;5;196m%s\033[49m" "$1"; }
bg_orange()    { printf "\033[48;5;208m%s\033[49m" "$1"; }
bg_yellow()    { printf "\033[48;5;220m%s\033[49m" "$1"; }
bg_green()     { printf "\033[48;5;34m%s\033[49m" "$1"; }
bg_teal()      { printf "\033[48;5;43m%s\033[49m" "$1"; }
bg_cyan()      { printf "\033[48;5;51m%s\033[49m" "$1"; }
bg_white()     { printf "\033[48;5;231m%s\033[49m" "$1"; }
bg_gray()      { printf "\033[48;5;245m%s\033[49m" "$1"; }

# 2. TIPOGRAFÍA DE BLOQUE

title() {
  printf "\033[0m\n"
  printf "  %s\n" "$(fw_underline "$(fw_bold "$(text_primary "$1")")")"
  printf "\033[0m\n"
}

subtitle() {
  printf "  %s\n\n\033[0m" "$(fw_italic "$(text_muted "$1")")"
}

paragraph() {
  printf "  %s\n\n\033[0m" "$1"
}

hr() {
  printf "\033[0m%s\n\033[0m" "$(text_muted "  -------------------------------------------------------")"
}

# 3. COMPONENTES (Alerts / Badges)

# Alertas sin fondo sólido para un diseño moderno (Borders / Icons style)
alert_danger()  { printf "\n  %s %s\n\n\033[0m" "$(text_danger "✖")" "$(text_danger "$(fw_bold "$1")")"; }
alert_success() { printf "\n  %s %s\n\n\033[0m" "$(text_success "✔")" "$(text_success "$(fw_bold "$1")")"; }
alert_info()    { printf "\n  %s %s\n\n\033[0m" "$(text_info "ℹ")" "$(text_info "$(fw_bold "$1")")"; }
alert_warning() { printf "\n  %s %s\n\n\033[0m" "$(text_warning "⚠")" "$(text_warning "$(fw_bold "$1")")"; }

# Badges (Cajitas con fondo invertido)
badge_primary()   { printf "%s" "$(bg_primary "$(text_light " $1 ")")"; }
badge_success()   { printf "%s" "$(bg_success "$(text_light " $1 ")")"; }
badge_danger()    { printf "%s" "$(bg_danger "$(text_light " $1 ")")"; }
badge_warning()   { printf "%s" "$(bg_warning "$(text_dark " $1 ")")"; }
badge_info()      { printf "%s" "$(bg_info "$(text_dark " $1 ")")"; }
badge_secondary() { printf "%s" "$(bg_secondary "$(text_light " $1 ")")"; }
badge_dark()      { printf "%s" "$(bg_dark "$(text_light " $1 ")")"; }

# 4. SPINNERS (Indicadores de progreso)

# Spinner ASCII simple (compatible con todos los terminales)
spinner() {
    local pid=$1
    local chars="/-\\|"
    local delay=0.1
    
    # Verificar que el PID existe
    if ! kill -0 $pid 2>/dev/null; then
        return 1
    fi
    
    # Ocultar cursor
    tput civis 2>/dev/null || true
    
    # Mientras el proceso esté vivo
    while kill -0 $pid 2>/dev/null; do
        for ((i=0; i<${#chars}; i++)); do
            printf "\r%s" "${chars:$i:1}"
            sleep $delay
        done
    done
    
    # Limpiar y restaurar cursor
    printf "\r"
    tput cnorm 2>/dev/null || true
}

# Spinner Unicode moderno (si el terminal lo soporta)
spinner_unicode() {
    local pid=$1
    local chars="·   ·  · ·  ·   ·  · ·  ·   ·"
    local delay=0.08
    
    if ! kill -0 $pid 2>/dev/null; then
        return 1
    fi
    
    tput civis 2>/dev/null || true
    
    while kill -0 $pid 2>/dev/null; do
        for ((i=0; i<${#chars}; i++)); do
            printf "\r%s" "${chars:$i:1}"
            sleep $delay
        done
    done
    
    printf "\r"
    tput cnorm 2>/dev/null || true
}

# Spinner de puntos animados
spinner_dots() {
    local pid=$1
    local delay=0.3
    
    if ! kill -0 $pid 2>/dev/null; then
        return 1
    fi
    
    tput civis 2>/dev/null || true
    
    while kill -0 $pid 2>/dev/null; do
        printf "."
        sleep $delay
    done
    
    # Limpiar la línea de puntos
    printf "\r$(printf "%*s" 30)\r"
    tput cnorm 2>/dev/null || true
}

# Helper para ejecutar comandos con spinner automáticamente
run_with_spinner() {
    local command="$1"
    local message="${2:-Procesando...}"
    local spinner_type="${3:-ascii}"
    
    # Mostrar mensaje inicial
    printf "%s" "$(text_info "$message") "
    
    # Ejecutar comando en background
    eval "$command" &
    local pid=$!
    
    # Elegir tipo de spinner
    case "$spinner_type" in
        "unicode"|"u")
            spinner_unicode $pid
            ;;
        "dots"|"d")
            spinner_dots $pid
            ;;
        *)
            spinner $pid
            ;;
    esac
    
    # Esperar y verificar resultado
    wait $pid
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        printf "%s\n" "$(text_success "¡Listo!")"
    else
        printf "%s\n" "$(text_danger "Error (código: $exit_code)")"
    fi
    
    return $exit_code
}

# Barra de progreso simple
progress_bar() {
    local current=$1
    local total=$2
    local width=${3:-30}
    local char=${4:-"="}
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r[%s%s] %d%%" "$(printf "%*s" $filled | tr ' ' "$char")" "$(printf "%*s" $empty)" "$percentage"
    
    if [[ $current -eq $total ]]; then
        printf "\n"
    fi
}