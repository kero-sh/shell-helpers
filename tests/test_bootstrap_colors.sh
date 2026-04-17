#!/usr/bin/env bash

# Test for new Bootstrap 5.3 color functions
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test Bootstrap 5.3 Colors ==="
echo

# Test 1: Body colors
echo "1. Body Colors:"
echo "$(text_body "text_body") $(text_body_emphasis "text_body_emphasis") $(text_body_secondary "text_body_secondary") $(text_body_tertiary "text_body_tertiary")"

echo
echo "2. Basic Colors:"
echo "$(text_black "text_black") $(text_white "$(bg_dark "text_white")")"

echo
echo "3. Emphasis Colors:"
echo "$(text_primary_emphasis "primary-emphasis") $(text_secondary_emphasis "secondary-emphasis") $(text_success_emphasis "success-emphasis")"
echo "$(text_danger_emphasis "danger-emphasis") $(text_warning_emphasis "warning-emphasis") $(text_info_emphasis "info-emphasis")"

echo
echo "4. Opacity Utilities:"
echo "$(text_opacity_25 "opacity-25") $(text_opacity_50 "opacity-50") $(text_opacity_75 "opacity-75") $(text_opacity_100 "opacity-100")"

echo
echo "5. Legacy Opacity (DEPRECATED):"
echo "$(text_black_50 "black-50") $(text_white_50 "$(bg_dark "white-50")")"

echo
echo "6. Comparison with existing:"
echo "Standard: $(text_primary "primary") vs Emphasis: $(text_primary_emphasis "primary-emphasis")"
echo "Standard: $(text_success "success") vs Emphasis: $(text_success_emphasis "success-emphasis")"

echo
echo "=== Test Completed ==="
