#!/usr/bin/env bash

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
        # 256-color terminals (check first to avoid pattern override)
        *xterm-256color*|*screen-256color*|*tmux-256color*|*alacritty*|*kitty*)
            return 0
            ;;
        # Modern and color-capable terminals
        *xterm*|*screen*|*tmux*|*rxvt*|*konsole*|*gnome*|*putty*|*cygwin*|*msys*|*mintty*)
            return 0
            ;;
        # Color variants
        *direct*|*truecolor*)
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
	local color
        color=$(echo "$1"|tr '[:upper:]' '[:lower:]')
	local title=$2
	shift 2
	local message="$*"
	# If QUIET/silent mode is enabled, suppress non-error output
	if [[ "${QUIET:-}" == "true" || "${QUIET:-}" == "1" ]]; then
		# Only allow printing errors (red/danger)
		if [[ "$color" != "red" && "$color" != "danger" ]]; then
			return 0
		fi
	fi
	
	{
		if may_color; then
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

function is_quiet() { [[ "${QUIET:-}" == "true" || "${QUIET:-}" == "1" ]]; }

function info()    { is_quiet || printf "%s %s\n" "$(text_info      "$(fw_bold "[ INFO  ]")")" "$*" >&2;}
function debug()   { is_quiet || printf "%s %s\n" "$(text_secondary "$(fw_bold "[ DEBUG ]")")" "$*" >&2;}
function error()   { is_quiet || printf "%s %s\n" "$(text_danger    "$(fw_bold "[ ERROR ]")")" "$*" >&2;}
function success() { is_quiet || printf "%s %s\n" "$(text_success   "$(fw_bold "[SUCCESS]")")" "$*" >&2;}
function warning() { is_quiet || printf "%s %s\n" "$(text_warning   "$(fw_bold "[WARNING]")")" "$*" >&2;}
function warn() { warning "$@"; }

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
	        local text="$*"

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
	local title="$*"
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
    date -v-"${days}"d -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-"${days}"d +"%Y-%m-%d" 2>/dev/null || echo ""
  else
    date -d "${days} days ago" -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -d "${days} days ago" -u +"%Y-%m-%d" 2>/dev/null || echo ""
  fi
}

# Function to calculate date in N days in ISO 8601 UTC format (macOS and Linux compatible)
function get_days_ahead_iso8601() {
  local days="${1:-1}"
  if [[ "$(uname)" == "Darwin" ]]; then
    date -v+"${days}"d -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v+"${days}"d +"%Y-%m-%d" 2>/dev/null || echo ""
  else
    date -d "${days} days" -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -d "${days} days" -u +"%Y-%m-%d" 2>/dev/null || echo ""
  fi
}

# ==========================================
# 🎨 UI FRAMEWORK (Bootstrap Style)
# ==========================================

# Readonly color variables for free usage
RC="\033[0m"  # Reset color

# Foreground colors
FG_RED="\033[38;5;196m"
FG_BLACK="\033[38;5;16m"
FG_GREEN="\033[38;5;34m"
FG_YELLOW="\033[38;5;220m"
FG_BLUE="\033[38;5;33m"
FG_INDIGO="\033[38;5;99m"
FG_MAGENTA="\033[38;5;135m"
FG_PINK="\033[38;5;162m"
FG_ORANGE="\033[38;5;208m"
FG_TEAL="\033[38;5;43m"
FG_CYAN="\033[38;5;51m"
FG_WHITE="\033[38;5;231m"
FG_GRAY="\033[38;5;245m"

# Background colors
BG_BLACK="\033[48;5;16m"
BG_RED="\033[48;5;196m"
BG_GREEN="\033[48;5;34m"
BG_YELLOW="\033[48;5;220m"
BG_BLUE="\033[48;5;33m"
BG_INDIGO="\033[48;5;99m"
BG_MAGENTA="\033[48;5;135m"
BG_PINK="\033[48;5;162m"
BG_ORANGE="\033[48;5;208m"
BG_TEAL="\033[48;5;43m"
BG_CYAN="\033[48;5;51m"
BG_WHITE="\033[48;5;231m"
BG_GRAY="\033[48;5;245m"
BG_LIGHT="\033[48;5;253m"
BG_DARK="\033[48;5;236m"

# 1. INLINE MODIFIERS
# Typography Styles (Composable).
fw_bold()      { printf "\033[1m%s\033[22m" "$1"; }
fw_dim()       { printf "\033[2m%s\033[22m" "$1"; }
fw_italic()    { printf "\033[3m%s\033[23m" "$1"; }
fw_underline() { printf "\033[4m%s\033[24m" "$1"; }
fw_reverse()   { printf "\033[7m%s\033[27m" "$1"; }
fw_strike()    { printf "\033[9m%s\033[29m" "$1"; }

# Text Colors (Foreground) using 256 color palette for more attractive design
text_primary()   { printf "${FG_BLUE}%s${RC}" "$1"; }     # Blue
text_secondary() { printf "${FG_GRAY}%s${RC}" "$1"; }    # Gray
text_success()   { printf "${FG_GREEN}%s${RC}" "$1"; }     # Green
text_danger()    { printf "${FG_RED}%s${RC}" "$1"; }    # Red
text_warning()   { printf "${FG_YELLOW}%s${RC}" "$1"; }    # Yellow/Orange
text_info()      { printf "${FG_CYAN}%s${RC}" "$1"; }     # Cyan
text_light()     { printf "${FG_WHITE}%s${RC}" "$1"; }    # Dim white
text_dark()      { printf "\033[38;5;236m%s\033[39m" "$1"; }    # Very dark gray
text_muted()     { printf "\033[38;5;246m%s\033[39m" "$1"; }    # Muted text (DEPRECATED in Bootstrap 5.3)

# Bootstrap 5.3 Body colors
text_body()           { printf "\033[38;5;250m%s\033[39m" "$1"; }  # Body text default
text_body_emphasis()  { printf "\033[1;38;5;250m%s\033[0m" "$1"; } # Body text emphasized
text_body_secondary() { printf "\033[38;5;245m%s\033[39m" "$1"; }  # Body text secondary
text_body_tertiary()  { printf "\033[38;5;243m%s\033[39m" "$1"; }  # Body text tertiary

# Bootstrap 5.3 Basic colors
text_black() { printf "${FG_BLACK}%s${RC}" "$1"; }   # Pure black
# shellcheck disable=SC2329
text_white() { printf "${FG_WHITE}%s${RC}" "$1"; }  # Pure white

# Export text_white for external use (used in some contexts)
export -f text_white

# Bootstrap 5.3 Emphasis colors (lighter variants)
text_primary_emphasis()   { printf "\033[38;5;111m%s\033[39m" "$1"; }  # Light blue
text_secondary_emphasis() { printf "\033[38;5;248m%s\033[39m" "$1"; }  # Light gray
text_success_emphasis()   { printf "\033[38;5;113m%s\033[39m" "$1"; }  # Light green
text_danger_emphasis()    { printf "\033[38;5;203m%s\033[39m" "$1"; }  # Light red
text_warning_emphasis()   { printf "\033[38;5;221m%s\033[39m" "$1"; }  # Light yellow
text_info_emphasis()      { printf "\033[38;5;117m%s\033[39m" "$1"; }  # Light cyan
text_light_emphasis()     { printf "\033[38;5;255m%s\033[39m" "$1"; }  # Very light white
text_dark_emphasis()      { printf "\033[38;5;238m%s\033[39m" "$1"; }  # Dark gray emphasis

# Bootstrap 5.3 Opacity utilities (simulated with lighter colors)
text_opacity_25() { printf "\033[38;5;254m%s\033[39m" "$1"; }  # 25% opacity (very light)
text_opacity_50() { printf "\033[38;5;248m%s\033[39m" "$1"; }  # 50% opacity (medium)
text_opacity_75() { printf "\033[38;5;240m%s\033[39m" "$1"; }  # 75% opacity (dark)
text_opacity_100() { printf "\033[38;5;232m%s\033[39m" "$1"; } # 100% opacity (complete)

# Bootstrap 5.3 Legacy opacity (deprecated but included for compatibility)
text_black_50() { printf "\033[38;5;242m%s\033[39m" "$1"; }  # Black 50% (DEPRECATED)
text_white_50() { printf "\033[38;5;248m%s\033[39m" "$1"; }  # White 50% (DEPRECATED)

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

border_primary_subtle()   { printf "\033[38;5;117m%s${RC}" "$1"; }   # Primary border subtle
border_secondary_subtle() { printf "\033[38;5;246m%s${RC}" "$1"; }   # Secondary border subtle
border_success_subtle()   { printf "\033[38;5;158m%s${RC}" "$1"; }   # Success border subtle
border_info_subtle()      { printf "\033[38;5;117m%s${RC}" "$1"; }   # Info border subtle
border_warning_subtle()   { printf "\033[38;5;229m%s${RC}" "$1"; }   # Warning border subtle
border_danger_subtle()    { printf "\033[38;5;203m%s${RC}" "$1"; }   # Danger border subtle
border_light_subtle()     { printf "\033[38;5;250m%s${RC}" "$1"; }   # Light border subtle
border_dark_subtle()      { printf "\033[38;5;245m%s${RC}" "$1"; }   # Dark border subtle

# Complete extended palette (Bootstrap style: blue, indigo, purple, pink, red, orange, yellow, green, teal, cyan, white, gray)
text_blue()      { printf "${FG_BLUE}%s${RC}" "$1"; }
text_indigo()    { printf "${FG_INDIGO}%s${RC}" "$1"; }
text_purple()    { printf "${FG_MAGENTA}%s${RC}" "$1"; }
text_pink()      { printf "${FG_PINK}%s${RC}" "$1"; }
text_red()       { printf "${FG_RED}%s${RC}" "$1"; }
text_orange()    { printf "${FG_ORANGE}%s${RC}" "$1"; }
text_yellow()    { printf "${FG_YELLOW}%s${RC}" "$1"; }
text_green()     { printf "${FG_GREEN}%s${RC}" "$1"; }
text_teal()      { printf "${FG_TEAL}%s${RC}" "$1"; }
text_cyan()      { printf "${FG_CYAN}%s${RC}" "$1"; }
text_white()     { printf "${FG_WHITE}%s${RC}" "$1"; }
text_gray()      { printf "${FG_GRAY}%s${RC}" "$1"; }    # Dim text

# Background colors
bg_primary()   { printf "${BG_BLUE}%s${RC}" "$1"; }
bg_secondary() { printf "${BG_GRAY}%s${RC}" "$1"; }
bg_success()   { printf "${BG_GREEN}%s${RC}" "$1"; }
bg_danger()    { printf "${BG_RED}%s${RC}" "$1"; }
bg_warning()   { printf "${BG_YELLOW}%s${RC}" "$1"; }
bg_info()      { printf "${BG_CYAN}%s${RC}" "$1"; }
bg_light()     { printf "${BG_LIGHT}%s${RC}" "$1"; }
bg_dark()      { printf "${BG_DARK}%s${RC}" "$1"; }

# Extended palette backgrounds
bg_black()     { printf "${BG_BLACK}%s${RC}" "$1"; }
bg_blue()      { printf "${BG_BLUE}%s${RC}" "$1"; }
bg_indigo()    { printf "${BG_INDIGO}%s${RC}" "$1"; }
bg_purple()    { printf "${BG_MAGENTA}%s${RC}" "$1"; }
bg_pink()      { printf "${BG_PINK}%s${RC}" "$1"; }
bg_red()       { printf "${BG_RED}%s${RC}" "$1"; }
bg_orange()    { printf "${BG_ORANGE}%s${RC}" "$1"; }
bg_yellow()    { printf "${BG_YELLOW}%s${RC}" "$1"; }
bg_green()     { printf "${BG_GREEN}%s${RC}" "$1"; }
bg_teal()      { printf "${BG_TEAL}%s${RC}" "$1"; }
bg_cyan()      { printf "${BG_CYAN}%s${RC}" "$1"; }
bg_white()     { printf "${BG_WHITE}%s${RC}" "$1"; }
bg_gray()      { printf "${BG_GRAY}%s${RC}" "$1"; }

# 2. BLOCK TYPOGRAPHY

title() {
  printf "\033[0m\n"
  printf "  %s\n" "$(fw_underline "$(fw_bold "$(text_warning "$1")")")"
  printf "\033[0m\n"
}

subtitle() {
  printf "  %s\n\n\033[0m" "$(fw_italic "$(text_yellow "$1")")"
}

paragraph() {
  printf "  %s\n\n\033[0m" "$1"
}

hr() {
  printf "\033[0m%s\n\033[0m" "$(text_muted "  -------------------------------------------------------")"
}

# 3. COMPONENTS (Alerts / Badges)

# Alerts without solid background for modern design (Borders / Icons style)
alert_danger()  { printf "\n  %s %s\n\n${RC}" "$(text_danger "✖")" "$(text_danger "$(fw_bold "$1")")"; }
alert_success() { printf "\n  %s %s\n\n${RC}" "$(text_success "✔")" "$(text_success "$(fw_bold "$1")")"; }
alert_info()    { printf "\n  %s %s\n\n${RC}" "$(text_info "ℹ")" "$(text_info "$(fw_bold "$1")")"; }
alert_warning() { printf "\n  %s %s\n\n${RC}" "$(text_warning "⚠")" "$(text_warning "$(fw_bold "$1")")"; }

# Badges (Boxes with inverted background)
badge_primary()   { printf "%s" "$(bg_primary "$(text_light " $1 ")")"; }
badge_success()   { printf "%s" "$(bg_success "$(text_light " $1 ")")"; }
badge_danger()    { printf "%s" "$(bg_danger "$(text_light " $1 ")")"; }
badge_warning()   { printf "%s" "$(bg_warning "$(text_dark " $1 ")")"; }
badge_info()      { printf "%s" "$(bg_info "$(text_dark " $1 ")")"; }
badge_secondary() { printf "%s" "$(bg_secondary "$(text_light " $1 ")")"; }
badge_dark()      { printf "%s" "$(bg_dark "$(text_light " $1 ")")"; }

# 4. SPINNERS (Progress indicators)

# Simple ASCII spinner (compatible with all terminals)
spinner() {
    local pid=$1
    local chars="/ - \\ |"
    local delay=0.1
    
    # Check if PID exists
    if ! kill -0 "$pid" 2>/dev/null; then
        return 1
    fi
    
    # Hide cursor
    tput civis 2>/dev/null || true
    
    # While process is alive
    while kill -0 "$pid" 2>/dev/null; do
        for ((i=0; i<${#chars}; i++)); do
            printf "\r%s" "${chars:$i:1}"
            sleep $delay
        done
    done
    
    # Clean and restore cursor
    printf "\r"
    tput cnorm 2>/dev/null || true
}

# Modern Unicode spinner (if terminal supports it)
spinner_unicode() {
    local pid=$1
    local chars="·   ·  · ·  ·   ·  · ·  ·   ·"
    local delay=0.08
    
    if ! kill -0 "$pid" 2>/dev/null; then
        return 1
    fi
    
    tput civis 2>/dev/null || true
    
    while kill -0 "$pid" 2>/dev/null; do
        for ((i=0; i<${#chars}; i++)); do
            printf "\r%s" "${chars:$i:1}"
            sleep $delay
        done
    done
    
    printf "\r"
    tput cnorm 2>/dev/null || true
}

# Animated dots spinner
spinner_dots() {
    local pid=$1
    local delay=0.3
    
    if ! kill -0 "$pid" 2>/dev/null; then
        return 1
    fi
    
    tput civis 2>/dev/null || true
    
    while kill -0 "$pid" 2>/dev/null; do
        printf "."
        sleep $delay
    done
    
    # Clear the dots line
    printf "\r%s\r" "$(printf "%*s" 30 '')"
    tput cnorm 2>/dev/null || true
}

# Helper to execute commands with spinner automatically
run_with_spinner() {
    local command="$1"
        local message="${2:-Processing...}"
    local spinner_type="${3:-ascii}"
    
    # Show initial message
    printf "%s" "$(text_info "$message") "
    
    # Execute command in background
    eval "$command" &
    local pid=$!
    
    # Choose spinner type
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
    
    # Wait and verify result
    wait $pid
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        printf "%s\n" "$(text_success "Done!")"
    else
        printf "%s\n" "$(text_danger "Error (code: $exit_code)")"
    fi
    
    return $exit_code
}

# Simple progress bar
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

# Function to generate argument lines for usage tables
# Usage: parse_arg "key" "value" "default" "description"
parse_arg() {
    local key="$1"
    local value="$2"

	if [ $# -gt 3 ]; then
		local default="$3"
		shift 3
	else
		local default=""
		shift 2
	fi

    local description="$*"
	local text_default=""
	if [ -n "$default" ]; then
		text_default="(default: $default)"
	fi
    printf "%s;%s;%s;%s\n" "$key" "$value" "$text_default" "$description"
}

max_length() {
    local max
	max=0    
    for num in "$@"; do
        if [[ $num -gt $max ]]; then
            max=$num
        fi
    done
    echo $((max+2))
}


# Function to format output of parse_arg() in a nice table
# Usage: { parse_arg "key1" "value" "desc1"; parse_arg "key2" "value" "desc2"; } | toUsage
toUsage() {	
	declare -a key_array value_array default_array description_array lines
  while IFS= read -r line; do
	lines+=("$line")
    local key_length value_length default_length description_length
    key_length=$(echo "$line" | cut -d';' -f1 | wc -c)
    value_length=$(echo "$line" | cut -d';' -f2 | wc -c)
    default_length=$(echo "$line" | cut -d';' -f3 | wc -c)
    description_length=$(echo "$line" | cut -d';' -f4 | wc -c)
    key_array+=("$key_length")
    value_array+=("$value_length")
    default_array+=("$default_length")
    description_array+=("$description_length")
    
  done

  # Get the maximums
  local max_key max_value max_default max_description
  max_key=$(max_length "${key_array[@]}")
  max_value=$(max_length "${value_array[@]}")
  max_default=$(max_length "${default_array[@]}")
  max_description=$(max_length "${description_array[@]}")
  
  # Print the table

  for line in "${lines[@]}"; do
	local key value default description
	key=$(echo "$line" | cut -d';' -f1)
	value=$(echo "$line" | cut -d';' -f2)
	default=$(echo "$line" | cut -d';' -f3)
	description=$(echo "$line" | cut -d';' -f4)
	
	# First line: key, value, default
	printf "%*s" "$1" ""
    printf "${FG_GREEN}%-${max_key}s${RC}" "$key"
    printf "  ${FG_YELLOW}%-${max_value}s${RC}" "$value"    
    if [ -n "$default" ]; then
		printf "  ${FG_CYAN}%-${max_default}s${RC}" "$default"
	fi
	echo
	
	# Second line: description with extra indentation if exists
	if [ -n "$description" ]; then
		printf "%*s" "$(( $1 + max_key + 4 ))" ""
		printf "${FG_WHITE}%-${max_description}s${RC}\n" "$description"
	fi
  done
  
}

# ==========================================
# 🛠️ UTILITY FUNCTIONS
# ==========================================

# Install yq tool across different operating systems
function install_yq() {
  case $(uname) in
    Darwin) brew install yq;;
    Linux)
      os=$(cat /etc/os-release | grep '^ID='|cut -d'=' -f2 | tr -d '"')
      case $os in
        alpine) apk add wget;;
        ubuntu|debian) apt update; apt install wget;;
        centos|fedora|rhel) yum install wget;;
      esac;

      mkdir -p ~/bin
      export PATH=~/bin:$PATH
      wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O ~/bin/yq && chmod +x ~/bin/yq
      ;;
      *)
      echo "Unsupported OS $(uname)"
      exit 1
    ;;
  esac
}

# Install jq tool across different operating systems
function install_jq() {
  case $(uname) in
    Darwin) brew install jq;;
    Linux)
      os=$(cat /etc/os-release | grep '^ID='|cut -d'=' -f2 | tr -d '"')
      case $os in
        alpine) apk add wget;;
        ubuntu|debian) apt update; apt install wget;;
        centos|fedora|rhel) yum install wget;;
      esac;

      mkdir -p ~/bin
      export PATH=~/bin:$PATH
      wget https://github.com/stedolan/jq/releases/latest/download/jq-linux64 -O ~/bin/jq && chmod +x ~/bin/jq
      ;;
      *)
      echo "Unsupported OS $(uname)"
      exit 1
    ;;
  esac
}

# Check if a log level should be displayed based on LATAM_LOG_LEVEL environment variable
# Usage: get_log_level "INFO" && echo "Show info message"
function get_log_level() {
  case "${LATAM_LOG_LEVEL:-"INFO"}" in
    QUIET) LL=0 ;;
    ERROR) LL=1 ;;
    WARN) LL=2 ;;
    INFO) LL=3 ;;
    DEBUG) LL=4 ;;
    *) LL=3 ;;
  esac

  case "$1" in
    QUIET) EE=0 ;;
    ERROR) EE=1 ;;
    WARN) EE=2 ;;
    INFO) EE=3 ;;
    DEBUG) EE=4 ;;
    *) EE=3 ;;
  esac

  if [ $LL -ge $EE ]; then
    return 0
  else
    return 1
  fi
}

# Verify that a file contains valid content (not just empty lines or comments)
# Usage: verify_empty_file "path/to/file"
function verify_empty_file() {
  local SRC=$1
  local total_lines=0
  local empty_or_comment_lines=0

  if [ -f "$SRC" ]; then
    while IFS= read -r line; do
      total_lines=$((total_lines + 1))
      trimmed_line=$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')
      if [[ -z "$trimmed_line" || "$trimmed_line" == \#* ]]; then
        empty_or_comment_lines=$((empty_or_comment_lines + 1))
      fi
    done < "$SRC"

    if [[ "$empty_or_comment_lines" -eq "$total_lines" ]]; then
      error "This file '$SRC' has not valid content... please check."
      exit 1
    else
      info "Content of file '$SRC' is valid!"
    fi
  else
    echo "File '$SRC' does not exist!"
    exit 1
  fi
}

# Sanitize string by removing quotes, spaces, and converting to lowercase
# Usage: sanitize "Hello World!" -> "helloworld!" or echo "Hello" | sanitize
function sanitize() {
  local input="${1:-}"
  # If no argument provided, read from stdin only if data is available
  if [[ -z "$input" ]] && [[ -t 0 ]]; then
    # No stdin available, return empty
    echo ""
    return
  elif [[ -z "$input" ]]; then
    # Read from stdin
    input=$(cat)
  fi
  echo "$input" | sed 's/'\''//g' | sed 's/"//g' | sed 's/ //g' | tr -d '\n' | tr -d '\r' | tr '[:upper:]' '[:lower:]'
}

# URL encode strings (requires jq)
# Usage: urlencode "Hello World!" -> "Hello%20World%21"
function urlencode() {
  local string="$*"
  jq -nr --arg str "$string" '$str|@uri'
}