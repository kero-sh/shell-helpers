#!/usr/bin/env bash

# Test for get_log_level function
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test get_log_level() Function ==="
echo

# Test 1: Default log level (INFO)
echo "Test 1: Default log level (INFO)"
unset LATAM_LOG_LEVEL
if get_log_level "INFO"; then
    echo "✓ PASS: Default INFO level allows INFO messages"
else
    echo "✗ FAIL: Default INFO level should allow INFO messages"
fi

if get_log_level "ERROR"; then
    echo "✓ PASS: Default INFO level allows ERROR messages"
else
    echo "✗ FAIL: Default INFO level should allow ERROR messages"
fi

if ! get_log_level "DEBUG"; then
    echo "✓ PASS: Default INFO level blocks DEBUG messages"
else
    echo "✗ FAIL: Default INFO level should block DEBUG messages"
fi

echo

# Test 2: QUIET log level
echo "Test 2: QUIET log level"
export LATAM_LOG_LEVEL="QUIET"
if ! get_log_level "ERROR"; then
    echo "✓ PASS: QUIET level blocks ERROR messages"
else
    echo "✗ FAIL: QUIET level should block ERROR messages"
fi

if ! get_log_level "INFO"; then
    echo "✓ PASS: QUIET level blocks INFO messages"
else
    echo "✗ FAIL: QUIET level should block INFO messages"
fi

echo

# Test 3: ERROR log level
echo "Test 3: ERROR log level"
export LATAM_LOG_LEVEL="ERROR"
if get_log_level "ERROR"; then
    echo "✓ PASS: ERROR level allows ERROR messages"
else
    echo "✗ FAIL: ERROR level should allow ERROR messages"
fi

if ! get_log_level "WARN"; then
    echo "✓ PASS: ERROR level blocks WARN messages"
else
    echo "✗ FAIL: ERROR level should block WARN messages"
fi

echo

# Test 4: WARN log level
echo "Test 4: WARN log level"
export LATAM_LOG_LEVEL="WARN"
if get_log_level "ERROR"; then
    echo "✓ PASS: WARN level allows ERROR messages"
else
    echo "✗ FAIL: WARN level should allow ERROR messages"
fi

if get_log_level "WARN"; then
    echo "✓ PASS: WARN level allows WARN messages"
else
    echo "✗ FAIL: WARN level should allow WARN messages"
fi

if ! get_log_level "INFO"; then
    echo "✓ PASS: WARN level blocks INFO messages"
else
    echo "✗ FAIL: WARN level should block INFO messages"
fi

echo

# Test 5: DEBUG log level
echo "Test 5: DEBUG log level"
export LATAM_LOG_LEVEL="DEBUG"
if get_log_level "DEBUG"; then
    echo "✓ PASS: DEBUG level allows DEBUG messages"
else
    echo "✗ FAIL: DEBUG level should allow DEBUG messages"
fi

if get_log_level "INFO"; then
    echo "✓ PASS: DEBUG level allows INFO messages"
else
    echo "✗ FAIL: DEBUG level should allow INFO messages"
fi

echo

# Test 6: Invalid log level (should default to INFO)
echo "Test 6: Invalid log level (should default to INFO)"
export LATAM_LOG_LEVEL="INVALID"
if get_log_level "INFO"; then
    echo "✓ PASS: Invalid level defaults to INFO behavior"
else
    echo "✗ FAIL: Invalid level should default to INFO behavior"
fi

if ! get_log_level "DEBUG"; then
    echo "✓ PASS: Invalid level blocks DEBUG (like INFO)"
else
    echo "✗ FAIL: Invalid level should block DEBUG (like INFO)"
fi

echo

# Test 7: Invalid message level (should default to INFO)
echo "Test 7: Invalid message level (should default to INFO)"
export LATAM_LOG_LEVEL="WARN"
if get_log_level "INVALID"; then
    echo "✓ PASS: Invalid message level defaults to INFO behavior"
else
    echo "✗ FAIL: Invalid message level should default to INFO behavior"
fi

echo

# Test 8: Case sensitivity
echo "Test 8: Case sensitivity"
export LATAM_LOG_LEVEL="info"
if get_log_level "INFO"; then
    echo "✓ PASS: Case insensitive log level works"
else
    echo "✗ FAIL: Case insensitive log level should work"
fi

# Clean up
unset LATAM_LOG_LEVEL

echo
echo "=== get_log_level() Test Completed ==="
