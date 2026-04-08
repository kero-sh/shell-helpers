# Changelog

All notable changes to this project will be documented in this file.

The format is based on Conventional Commits, and this file is automatically updated by the release workflow.

## [2.0.0] - 2024-04-08

### BREAKING CHANGES
- Complete refactor to Bootstrap 5.3 UI framework
- Enhanced terminal and CI/CD compatibility
- Deprecated old color functions (still available for backward compatibility)

### FEAT
- **Bootstrap 5.3 UI Framework**: Complete implementation with 150+ color functions
- **Typography Modifiers**: Bold, italic, underline, strikethrough and combinations
- **Color Variants**: 100-900 scale for all theme colors (blue, green, red, yellow, gray)
- **Emphasis Colors**: Light variants of all semantic colors
- **Body Colors**: Bootstrap 5.3 body text utilities
- **Opacity Utilities**: 25%, 50%, 75%, 100% opacity functions
- **Subtle Utilities**: Background and border subtle variants
- **UI Components**: Alerts, badges, titles, subtitles, paragraphs, horizontal rules
- **Spinners**: ASCII, Unicode, and dots spinners with auto-management
- **Progress Bar**: Manual progress bar function
- **Enhanced Logging**: Refactored with Bootstrap 5.3 colors and formatting

### ENHANCE
- **Modern Terminal Support**: iTerm, Warp, WezTerm, VS Code, Alacritty, Kitty
- **CI/CD Compatibility**: GitHub Actions, GitLab CI, Jenkins detection
- **Smart Color Detection**: Respects NO_COLOR and adapts to terminal capabilities
- **TTY Detection**: Enhanced detection for interactive and non-interactive environments
- **Quiet Mode**: Improved QUIET environment variable handling
- **Cross-Platform**: Better macOS, Linux, Windows (WSL/Cygwin) support

### FIX
- **Syntax Errors**: Fixed all shellcheck warnings and bash syntax issues
- **Pattern Overrides**: Fixed duplicate patterns in case statements
- **Variable Handling**: Corrected array handling ($@ vs $*)
- **Function Declarations**: Fixed missing braces and syntax errors
- **Printf Formatting**: Fixed format string issues with multiple variables

### REFACTOR
- **Old Functions**: Refactored to use new Bootstrap framework underneath
- **Color Functions**: Deprecated basic colors, now use semantic equivalents
- **Logging Functions**: Enhanced with new color framework while maintaining compatibility
- **Title Functions**: Unified printtitle() with title() preserving user-preferred style
- **Dependency Management**: Improved command checking and error handling

### TEST
- **Comprehensive Test Suite**: Added tests for all new features
- **Bootstrap Colors Test**: Complete color function validation
- **Compatibility Test**: Backward compatibility verification
- **Terminal Detection Test**: Modern terminal and CI/CD detection
- **Spinner Test**: All spinner types and auto-management
- **UI Demo**: Complete framework demonstration

### DOCS
- **README Update**: Complete documentation of 150+ functions
- **Function Reference**: Detailed API documentation with examples
- **Migration Guide**: Examples for upgrading from v1.x to v2.0
- **Environment Variables**: Documentation of all supported variables

### DEPRECATE
- **Basic Color Functions**: `red()`, `green()`, `blue()`, `yellow()` (use semantic colors)
- **Legacy Functions**: `printtitle()` (use `title()` for new Bootstrap style)
- **Text Muted**: `text_muted()` (deprecated in Bootstrap 5.3)

### SECURITY
- **Input Validation**: Enhanced parameter validation
- **Shell Injection Prevention**: Safer command execution
- **Environment Variable Handling**: Secure variable processing

## [1.0.3] - Previous Release

- Maintenance release with bug fixes and improvements

