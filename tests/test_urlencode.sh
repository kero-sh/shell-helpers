#!/usr/bin/env bash

# Test for urlencode function
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test urlencode() Function ==="
echo

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
    echo "⚠️  WARNING: jq is not available. Some tests may fail."
    echo "Install jq with: brew install jq (macOS) or apt/yum install jq (Linux)"
    echo
fi

# Test 1: Basic URL encoding
echo "Test 1: Basic URL encoding"
result=$(urlencode "Hello World")
expected="Hello%20World"
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: Basic space encoding works"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 2: Special characters
echo "Test 2: Special characters"
result=$(urlencode "Hello@World!")
expected="Hello%40World%21"
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: Special characters encoded correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 3: Multiple spaces
echo "Test 3: Multiple spaces"
result=$(urlencode "Hello  World")
expected="Hello%20%20World"
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: Multiple spaces encoded correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 4: URL-like string
echo "Test 4: URL-like string"
result=$(urlencode "https://example.com/path with spaces")
expected="https%3A//example.com/path%20with%20spaces"
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: URL-like string encoded correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 5: Query parameters
echo "Test 5: Query parameters"
result=$(urlencode "name=John Doe&age=30")
expected="name%3DJohn%20Doe%26age%3D30"
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: Query parameters encoded correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 6: Empty string
echo "Test 6: Empty string"
result=$(urlencode "")
expected=""
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: Empty string handled correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 7: String with quotes
echo "Test 7: String with quotes"
result=$(urlencode 'Hello "World"')
expected="Hello%20%22World%22"
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: Quotes encoded correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 8: Unicode characters
echo "Test 8: Unicode characters"
result=$(urlencode "café")
expected="caf%C3%A9"
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: Unicode characters encoded correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 9: Multiple arguments
echo "Test 9: Multiple arguments"
result=$(urlencode "Hello" "World")
expected="Hello%20World"
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: Multiple arguments concatenated correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 10: No arguments
echo "Test 10: No arguments"
result=$(urlencode)
expected=""
if [[ "$result" == "$expected" ]]; then
    echo "✓ PASS: No arguments handled correctly"
else
    echo "✗ FAIL: Expected '$expected', got '$result'"
fi

echo
echo "=== urlencode() Test Completed ==="
