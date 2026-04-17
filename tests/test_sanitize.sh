#!/usr/bin/env bash

# Test for sanitize function
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test sanitize() Function ==="
echo

# Test 1: Basic string sanitization
echo "Test 1: Basic string sanitization"
result=$(sanitize "Hello World!")
expected="helloworld!"
if [[ "$result" == "$expected" ]]; then
    echo " PASS: Basic sanitization works"
else
    echo " FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 2: Remove quotes
echo "Test 2: Remove quotes"
result=$(sanitize 'Hello"World"')
expected="helloworld"
if [[ "$result" == "$expected" ]]; then
    echo " PASS: Quotes removed correctly"
else
    echo " FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 3: Handle single quotes
echo "Test 3: Handle single quotes"
result=$(sanitize "Hello'World'")
expected="helloworld"
if [[ "$result" == "$expected" ]]; then
    echo " PASS: Single quotes removed correctly"
else
    echo " FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 4: Convert to lowercase
echo "Test 4: Convert to lowercase"
result=$(sanitize "UPPERCASE")
expected="uppercase"
if [[ "$result" == "$expected" ]]; then
    echo " PASS: Lowercase conversion works"
else
    echo " FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 5: Handle empty string
echo "Test 5: Handle empty string"
result=$(sanitize "")
expected=""
if [[ "$result" == "$expected" ]]; then
    echo " PASS: Empty string handled correctly"
else
    echo " FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 6: Handle no arguments
echo "Test 6: Handle no arguments"
result=$(sanitize)
expected=""
if [[ "$result" == "$expected" ]]; then
    echo " PASS: No arguments handled correctly"
else
    echo " FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 7: Remove newlines and carriage returns
echo "Test 7: Remove newlines and carriage returns"
result=$(printf "Hello\nWorld\r" | sanitize)
expected="helloworld"
if [[ "$result" == "$expected" ]]; then
    echo " PASS: Newlines and carriage returns removed"
else
    echo " FAIL: Expected '$expected', got '$result'"
fi

echo

# Test 8: Complex string with special characters
echo "Test 8: Complex string with special characters"
result=$(sanitize 'Hello "World"! @#$%^&*()')
expected="helloworld!@#$%^&*()"
if [[ "$result" == "$expected" ]]; then
    echo " PASS: Complex string handled correctly"
else
    echo " FAIL: Expected '$expected', got '$result'"
fi

echo
echo "=== sanitize() Test Completed ==="
