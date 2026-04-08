# Shell Helpers

[![Language](https://img.shields.io/badge/language-Shell%20Script-blue.svg)](https://en.wikipedia.org/wiki/Shell_script)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![bash](https://img.shields.io/badge/bash-5.3-blue)](#) [![zsh](https://img.shields.io/badge/zsh-5.9-blue)](#)
[![Version](https://img.shields.io/badge/version-2.0.0-green.svg)](https://github.com/kero-sh/shell-helpers/releases/tag/v2.0.0)

A comprehensive Bootstrap 5.3-inspired UI framework for shell scripting, designed to make your scripts more robust, colorful, and user-friendly with modern terminal support.

## Features

### UI Framework (Bootstrap 5.3 Style)
- **150+ Color Functions**: Complete Bootstrap 5.3 color palette with semantic naming
- **Typography Modifiers**: Bold, italic, underline, strikethrough, and combinations
- **Components**: Alerts, badges, and UI elements with modern styling
- **Color Variants**: 100-900 scale for all theme colors
- **Subtle Utilities**: Background and border subtle variants
- **Spinners**: ASCII, Unicode, and dots spinners with auto-management

### Enhanced Terminal Support
- **Modern Terminals**: iTerm, Warp, WezTerm, VS Code, Alacritty, Kitty
- **CI/CD Compatibility**: GitHub Actions, GitLab CI, Jenkins with automatic TTY detection
- **Smart Color Detection**: Respects NO_COLOR and adapts to terminal capabilities
- **Cross-Platform**: macOS, Linux, Windows (WSL/Cygwin)

### Core Functionality
- **Colorful Logging**: Enhanced logging with Bootstrap-style colors and formatting
- **Confirmation Prompts**: Smart prompts that work in CI/CD environments
- **Dependency Checking**: Verify required CLI tools are installed
- **Quiet Mode**: Suppress output when needed (respecting QUIET environment variable)

## Prerequisites

These scripts have been tested with the following shell versions:

-   **Zsh**: `5.9` or higher
-   **GNU Bash**: `5.3.3` or higher

**Important:** The default `bash` version included with macOS (typically `3.2.57`) is **not** supported and may cause unexpected issues. It is highly recommended to use a modern version of Zsh or install a newer version of Bash (e.g., via Homebrew).

## Installation & Usage

To use these helper functions, simply source the `helpers.sh` script at the beginning of your own shell script:

```bash
#!/bin/bash

# Source the helpers
source "path/to/your/libs/helpers.sh"

# Now you can use the functions
info "This is an informational message."
warn "This is a warning."
error "This is an error."

if confirm "Do you want to proceed?"; then
  success "Great! Proceeding..."
else
  fatal "Operation aborted by the user."
fi
```

## Examples

### Bootstrap 5.3 UI Framework

The new UI framework provides modern, Bootstrap-inspired styling for your scripts.

#### Typography & Colors

```bash
#!/bin/bash

source "libs/helpers.sh"

# Modern typography
title "Main Title"
subtitle "Descriptive subtitle"
paragraph "This is regular paragraph text."

# Bootstrap 5.3 semantic colors
echo "$(text_primary "Primary text in Bootstrap blue")"
echo "$(text_success "Success text in Bootstrap green")"
echo "$(text_danger "Danger text in Bootstrap red")"
echo "$(text_warning "Warning text in Bootstrap yellow")"
echo "$(text_info "Info text in Bootstrap cyan")"

# Color variants (100-900 scale)
echo "$(text_blue_300 "Light blue text")"
echo "$(text_blue_600 "Medium blue text")"
echo "$(text_blue_900 "Dark blue text")"

# Typography modifiers
echo "$(fw_bold "Bold text")"
echo "$(fw_italic "Italic text")"
echo "$(fw_underline "Underlined text")"
echo "$(fw_strikethrough "Strikethrough text")"
```

#### UI Components

```bash
#!/bin/bash

source "libs/helpers.sh"

# Alerts
alert_success "Operation completed successfully!"
alert_warning "Please review the following warnings."
alert_danger "Critical error occurred!"
alert_info "Additional information available."

# Badges
echo "Status: $(badge_primary "Active")"
echo "Version: $(badge_success "v2.0.0")"
echo "State: $(badge_danger "Error")"

# Spinners
run_with_spinner "sleep 3" "Downloading file..." "ascii"
run_with_spinner "curl -s api.example.com" "Processing data..." "unicode"

# Progress bar
for i in {1..10}; do
    progress_bar $i 10
    sleep 0.3
done
```

### Enhanced Logging

The logging functions now use Bootstrap 5.3 colors and smart terminal detection.

```bash
#!/bin/bash

source "libs/helpers.sh"

# Set quiet mode (suppresses non-error output)
export QUIET=false

info "Starting the script..."
debug "This is a debug message."
warn "A non-critical issue occurred."
error "Something went wrong!"
success "Operation completed successfully."

# The fatal function will exit the script with status 1
fatal "A critical error occurred. Exiting."
```

### CI/CD Compatibility

The framework automatically detects CI/CD environments and adapts accordingly.

```bash
#!/bin/bash

source "libs/helpers.sh"

# This works in both interactive terminals and CI/CD
if confirm "Do you want to proceed with deployment?"; then
    run_with_spinner "deploy_application" "Deploying application..." "dots"
    success "Deployment completed!"
else
    warn "Deployment cancelled."
fi

# Smart color detection - works in all environments
echo "$(text_primary "This message will be colored appropriately for your environment")"
```

### Ensuring Dependencies

Check for required command-line tools at the start of your script.

```bash
#!/bin/bash

source "libs/helpers.sh"

# Check if 'jq' and 'glab' are available in the PATH
# The script will print an error and exit if they are not found.
ensure_dependencies jq glab

info "All required dependencies are installed."
# Continue with your script logic
```

## Function Reference

### Logging (Bootstrap 5.3 Styled)
- `success <message>` - Green success message
- `info <message>` - Blue informational message  
- `warn <message>` / `warning <message>` - Yellow warning message
- `error <message>` - Red error message
- `debug <message>` - Gray debug message
- `fatal <message>` - Red fatal message (exits script)

### Typography Modifiers
- `fw_bold <text>` - Bold text
- `fw_italic <text>` - Italic text
- `fw_underline <text>` - Underlined text
- `fw_strikethrough <text>` - Strikethrough text
- `fw_bold_italic <text>` - Bold and italic
- `fw_bold_underline <text>` - Bold and underlined
- `fw_italic_underline <text>` - Italic and underlined
- `fw_bold_italic_underline <text>` - Bold, italic, and underlined

### Bootstrap 5.3 Semantic Colors
- `text_primary <text>` - Primary blue
- `text_secondary <text>` - Secondary gray
- `text_success <text>` - Success green
- `text_danger <text>` - Danger red
- `text_warning <text>` - Warning yellow
- `text_info <text>` - Info cyan
- `text_light <text>` - Light gray
- `text_dark <text>` - Dark gray
- `text_muted <text>` - Muted gray (deprecated in 5.3)

### Bootstrap 5.3 Body Colors
- `text_body <text>` - Body text default
- `text_body_emphasis <text>` - Body text emphasized
- `text_body_secondary <text>` - Body text secondary
- `text_body_tertiary <text>` - Body text tertiary

### Basic Colors
- `text_black <text>` - Pure black
- `text_white <text>` - Pure white
- `text_blue <text>` - Blue
- `text_indigo <text>` - Indigo
- `text_purple <text>` - Purple
- `text_pink <text>` - Pink
- `text_red <text>` - Red
- `text_orange <text>` - Orange
- `text_yellow <text>` - Yellow
- `text_green <text>` - Green
- `text_teal <text>` - Teal
- `text_cyan <text>` - Cyan
- `text_gray <text>` - Gray

### Color Variants (100-900 Scale)
- `text_blue_100` to `text_blue_900`
- `text_green_100` to `text_green_900`
- `text_red_100` to `text_red_900`
- `text_yellow_100` to `text_yellow_900`
- `text_gray_100` to `text_gray_900`

### Emphasis Colors
- `text_primary_emphasis <text>` - Light primary
- `text_secondary_emphasis <text>` - Light secondary
- `text_success_emphasis <text>` - Light success
- `text_danger_emphasis <text>` - Light danger
- `text_warning_emphasis <text>` - Light warning
- `text_info_emphasis <text>` - Light info
- `text_light_emphasis <text>` - Very light
- `text_dark_emphasis <text>` - Dark emphasis

### Opacity Utilities
- `text_opacity_25 <text>` - 25% opacity
- `text_opacity_50 <text>` - 50% opacity
- `text_opacity_75 <text>` - 75% opacity
- `text_opacity_100 <text>` - 100% opacity

### Background Colors
- `bg_primary <text>` - Primary background
- `bg_secondary <text>` - Secondary background
- `bg_success <text>` - Success background
- `bg_danger <text>` - Danger background
- `bg_warning <text>` - Warning background
- `bg_info <text>` - Info background
- `bg_light <text>` - Light background
- `bg_dark <text>` - Dark background

### Subtle Utilities
- `bg_primary_subtle <text>` - Primary subtle background
- `bg_secondary_subtle <text>` - Secondary subtle background
- `bg_success_subtle <text>` - Success subtle background
- `bg_danger_subtle <text>` - Danger subtle background
- `bg_warning_subtle <text>` - Warning subtle background
- `bg_info_subtle <text>` - Info subtle background
- `bg_light_subtle <text>` - Light subtle background
- `bg_dark_subtle <text>` - Dark subtle background

### UI Components
- `title <text>` - Main title with underline
- `subtitle <text>` - Subtitle in muted italic
- `paragraph <text>` - Regular paragraph text
- `hr` - Horizontal rule
- `alert_success <message>` - Success alert
- `alert_warning <message>` - Warning alert
- `alert_danger <message>` - Danger alert
- `alert_info <message>` - Info alert
- `badge_primary <text>` - Primary badge
- `badge_success <text>` - Success badge
- `badge_danger <text>` - Danger badge
- `badge_warning <text>` - Warning badge
- `badge_info <text>` - Info badge
- `badge_secondary <text>` - Secondary badge
- `badge_dark <text>` - Dark badge

### Spinners
- `spinner <pid>` - ASCII spinner
- `spinner_unicode <pid>` - Unicode spinner
- `spinner_dots <pid>` - Dots spinner
- `run_with_spinner <command> <message> <type>` - Auto spinner
- `progress_bar <current> <total> <width> <char>` - Progress bar

### Utilities
- `confirm [prompt]` - User confirmation prompt
- `ensure_commands <cmd1> [cmd2] ...` - Check command availability
- `ensure_dependencies <cmd1> [cmd2] ...` - Check commands + setup GitLab
- `printtitle <title>` - Legacy title (deprecated)
- `has_tty_available` - Check TTY availability
- `may_color` - Check color support
- `is_quiet` - Check QUIET mode

### Environment Variables
- `QUIET=true|1` - Suppress non-error output
- `NO_COLOR=1` - Disable colors (standard)
- `CI=true` - CI/CD environment detection
- `TERM_PROGRAM` - Terminal program detection

---

## Support

If you find this collection of helpers useful, please consider supporting my work.

<a href="https://www.buymeacoffee.com/caherrera" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
