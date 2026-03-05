function may_color() {
	case "$TERM" in
        *color*|*256*|xterm*|screen*|tmux*)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

function yellow() {
	printf "\033[0;33m%s\033[0m" "$@"
}

function red() {
	printf "\033[0;31m%s\033[0m" "$@"
}
function green() {
	printf "\033[0;32m%s\033[0m" "$@"
}
function blue() {
	printf "\033[0;34m%s\033[0m" "$@"
}


function echoc() {
	local color=$(echo "$1"|tr '[:upper:]' '[:lower:]')
	local title=$2
	shift 2
	local message=$@
	# If QUIET/silent mode is enabled, suppress non-error output
	if [[ "${QUIET:-}" == "true" || "${QUIET:-}" == "1" ]]; then
		# Only allow printing errors (red)
		if [[ "$color" != "red" ]]; then
			return 0
		fi
	fi
	{
		if $(may_color); then
			case "$color" in
			red)
				printf "%s %s" $(red "$title") "$message"
				;;
			green)
				printf "%s %s" $(green "$title") "$message"
				;;
			yellow)
				printf "%s %s" $(yellow "$title") "$message"
				;;
			blue)
				printf "%s %s" $(blue "$title") "$message"
				;;
			*)
				echo -n $message
				;;
			esac
		else
			echo -n "$title $message"
		fi
		echo
	} >&2
}


function info() {
	echoc "blue" "[INFO]" "$@" >&2
}
function debug() {
	echoc "" "[DEBUG]" "$@" >&2
}
function error() {
	echoc "red" "[ERROR]" "$@" >&2
}
function warn() {
	echoc "yellow" "[WARN]" "$@" >&2
}

function success() {
	echoc "green" "[SUCCESS]" "$@" >&2
}

function warning() {
  echoc "yellow" "[WARN]" "$@" >&2
}

function has_tty_available() {
	if [[ -t 0 || -t 1 || -t 2 ]]; then
		return 0
	fi
	if [[ -r /dev/tty && -w /dev/tty ]]; then
		return 0
	fi
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

function printtitle() {
	local title="$@"
	info "********************************************"
	info "*** $title ***"
	info "********************************************"
	
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