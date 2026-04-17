#!/usr/bin/env bash

# Compatibility test for refactored functions
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test Refactored Functions Compatibility ==="
echo

# Test 1: Basic logging functions
echo "Test 1: Basic logging functions"
info "This is an info message"
debug "This is a debug message"
warn "This is a warning message"
error "This is an error message"
success "This is a success message"

echo
echo "Test 2: Verify QUIET mode"
export QUIET=true
info "This message should NOT be visible (QUIET=true)"
debug "This message should NOT be visible (QUIET=true)"
warn "This message should NOT be visible (QUIET=true)"
error "This message SHOULD be visible (error always shows)"
success "This message should NOT be visible (QUIET=true)"
unset QUIET

echo
echo "Test 3: Multiple parameters"
info "Info with" "multiple" "parameters"
warn "Warning with" "various" "arguments"

echo
echo "Test 4: Redirection compatibility"
info "Redirected to stderr" 2>/dev/null
echo "If there are no info messages above, redirection worked"

echo
echo "Test 5: Verify warning() no longer exists"
if type warning >/dev/null 2>&1; then
    echo "ERROR: warning() still exists (should have been removed)"
else
    echo "OK: warning() was correctly removed"
fi

echo
echo "=== Test Completed ==="
