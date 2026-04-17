#!/usr/bin/env bash
# shellcheck disable=SC1091

# Comprehensive test for all new functions added from LATAM helpers.sh
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Comprehensive Test for New Functions ==="
echo

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper function to run a test and track results
run_test() {
    local test_name="$1"
    local test_script="$2"
    
    echo "Running $test_name..."
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if bash "$test_script" 2>/dev/null | grep -q " PASS"; then
        echo "× $test_name PASSED"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "× $test_name FAILED"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo
}

# Get the directory where this script is located
TEST_DIR="$(dirname "$0")"

# Run all new function tests
run_test "sanitize() function" "$TEST_DIR/test_sanitize.sh"
run_test "get_log_level() function" "$TEST_DIR/test_get_log_level.sh"
run_test "verify_empty_file() function" "$TEST_DIR/test_verify_empty_file.sh"
run_test "urlencode() function" "$TEST_DIR/test_urlencode.sh"
run_test "install tools functions" "$TEST_DIR/test_install_tools.sh"

# Summary
echo "=== Test Summary ==="
echo "Total tests run: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo "?? All tests passed!"
else
    echo "?? Some tests failed. Please check the individual test outputs."
fi
