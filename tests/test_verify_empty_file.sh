#!/usr/bin/env bash

# Test for verify_empty_file function
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test verify_empty_file() Function ==="
echo

# Create test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Test 1: File with valid content
echo "Test 1: File with valid content"
echo "valid content" > "$TEST_DIR/valid.txt"
if (verify_empty_file "$TEST_DIR/valid.txt" 2>/dev/null); then
    echo "✓ PASS: Valid file accepted"
else
    echo "✗ FAIL: Valid file should be accepted"
fi

echo

# Test 2: Empty file
echo "Test 2: Empty file"
touch "$TEST_DIR/empty.txt"
if ! (verify_empty_file "$TEST_DIR/empty.txt" 2>/dev/null); then
    echo "✓ PASS: Empty file rejected"
else
    echo "✗ FAIL: Empty file should be rejected"
fi

echo

# Test 3: File with only comments
echo "Test 3: File with only comments"
cat > "$TEST_DIR/comments.txt" << EOF
# This is a comment
# Another comment
  # Indented comment
EOF
if ! (verify_empty_file "$TEST_DIR/comments.txt" 2>/dev/null); then
    echo "✓ PASS: Comment-only file rejected"
else
    echo "✗ FAIL: Comment-only file should be rejected"
fi

echo

# Test 4: File with mixed content (comments and valid content)
echo "Test 4: File with mixed content"
cat > "$TEST_DIR/mixed.txt" << EOF
# This is a comment
valid content here
# Another comment
EOF
if (verify_empty_file "$TEST_DIR/mixed.txt" 2>/dev/null); then
    echo "✓ PASS: Mixed content file accepted"
else
    echo "✗ FAIL: Mixed content file should be accepted"
fi

echo

# Test 5: File with only whitespace and comments
echo "Test 5: File with only whitespace and comments"
cat > "$TEST_DIR/whitespace.txt" << EOF
   
# Comment after whitespace
	
	# Indented comment with tabs
   
EOF
if ! (verify_empty_file "$TEST_DIR/whitespace.txt" 2>/dev/null); then
    echo "✓ PASS: Whitespace and comments file rejected"
else
    echo "✗ FAIL: Whitespace and comments file should be rejected"
fi

echo

# Test 6: File with whitespace and valid content
echo "Test 6: File with whitespace and valid content"
cat > "$TEST_DIR/whitespace_valid.txt" << EOF
   
# Comment
   
   valid content after whitespace
   
EOF
if (verify_empty_file "$TEST_DIR/whitespace_valid.txt" 2>/dev/null); then
    echo "✓ PASS: Whitespace with valid content accepted"
else
    echo "✗ FAIL: Whitespace with valid content should be accepted"
fi

echo

# Test 7: Non-existent file
echo "Test 7: Non-existent file"
if ! (verify_empty_file "$TEST_DIR/nonexistent.txt" 2>/dev/null); then
    echo "✓ PASS: Non-existent file rejected"
else
    echo "✗ FAIL: Non-existent file should be rejected"
fi

echo

# Test 8: File with single character
echo "Test 8: File with single character"
echo "a" > "$TEST_DIR/single.txt"
if (verify_empty_file "$TEST_DIR/single.txt" 2>/dev/null); then
    echo "✓ PASS: Single character file accepted"
else
    echo "✗ FAIL: Single character file should be accepted"
fi

echo

# Test 9: File with multiple valid lines
echo "Test 9: File with multiple valid lines"
cat > "$TEST_DIR/multiline.txt" << EOF
# Configuration file
setting1=value1
setting2=value2
# End of file
EOF
if (verify_empty_file "$TEST_DIR/multiline.txt" 2>/dev/null); then
    echo "✓ PASS: Multi-line valid file accepted"
else
    echo "✗ FAIL: Multi-line valid file should be accepted"
fi

echo
echo "=== verify_empty_file() Test Completed ==="
