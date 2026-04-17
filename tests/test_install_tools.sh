#!/usr/bin/env bash

# Test for install_jq() and install_yq() functions
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test install_jq() and install_yq() Functions ==="
echo

# Test 1: Check if functions exist
echo "Test 1: Check if functions exist"
if declare -f install_jq >/dev/null; then
    echo "✓ PASS: install_jq() function exists"
else
    echo "✗ FAIL: install_jq() function not found"
fi

if declare -f install_yq >/dev/null; then
    echo "✓ PASS: install_yq() function exists"
else
    echo "✗ FAIL: install_yq() function not found"
fi

echo

# Test 2: Check OS detection
echo "Test 2: Check OS detection"
current_os=$(uname)
echo "Current OS: $current_os"

case $current_os in
    Darwin)
        echo "✓ INFO: macOS detected - should use brew"
        ;;
    Linux)
        if [[ -f /etc/os-release ]]; then
            linux_os=$(cat /etc/os-release | grep '^ID=' | cut -d'=' -f2 | tr -d '"')
            echo "✓ INFO: Linux detected - distribution: $linux_os"
        else
            echo "⚠️  WARNING: Linux detected but cannot determine distribution"
        fi
        ;;
    *)
        echo "⚠️  WARNING: Unsupported OS detected: $current_os"
        ;;
esac

echo

# Test 3: Check if tools are already installed
echo "Test 3: Check if tools are already installed"

if command -v jq >/dev/null 2>&1; then
    jq_version=$(jq --version 2>/dev/null || echo "unknown")
    echo "✓ INFO: jq is already installed (version: $jq_version)"
    jq_installed=true
else
    echo "ℹ️  INFO: jq is not installed"
    jq_installed=false
fi

if command -v yq >/dev/null 2>&1; then
    yq_version=$(yq --version 2>/dev/null || echo "unknown")
    echo "✓ INFO: yq is already installed (version: $yq_version)"
    yq_installed=true
else
    echo "ℹ️  INFO: yq is not installed"
    yq_installed=false
fi

echo

# Test 4: Test function behavior without actually installing
echo "Test 4: Test function behavior (dry run)"

# We'll test the OS detection logic without actually running the install
# by examining what the function would do on this system

echo "Testing install_jq() logic..."
case $(uname) in
    Darwin)
        echo "Would run: brew install jq"
        ;;
    Linux)
        if [[ -f /etc/os-release ]]; then
            os=$(cat /etc/os-release | grep '^ID='|cut -d'=' -f2 | tr -d '"')
            case $os in
                alpine) echo "Would run: apk add wget; then download jq" ;;
                ubuntu|debian) echo "Would run: apt update; apt install wget; then download jq" ;;
                centos|fedora|rhel) echo "Would run: yum install wget; then download jq" ;;
                *) echo "Would attempt generic Linux installation" ;;
            esac
        fi
        ;;
    *)
        echo "Would show: Unsupported OS $(uname)"
        ;;
esac

echo

echo "Testing install_yq() logic..."
case $(uname) in
    Darwin)
        echo "Would run: brew install yq"
        ;;
    Linux)
        if [[ -f /etc/os-release ]]; then
            os=$(cat /etc/os-release | grep '^ID='|cut -d'=' -f2 | tr -d '"')
            case $os in
                alpine) echo "Would run: apk add wget; then download yq" ;;
                ubuntu|debian) echo "Would run: apt update; apt install wget; then download yq" ;;
                centos|fedora|rhel) echo "Would run: yum install wget; then download yq" ;;
                *) echo "Would attempt generic Linux installation" ;;
            esac
        fi
        ;;
    *)
        echo "Would show: Unsupported OS $(uname)"
        ;;
esac

echo

# Test 5: Test basic functionality of installed tools (if available)
echo "Test 5: Test basic functionality of installed tools"

if [[ "$jq_installed" == true ]]; then
    echo "Testing jq functionality..."
    test_json='{"test": "value"}'
    if echo "$test_json" | jq . >/dev/null 2>&1; then
        echo "✓ PASS: jq can parse JSON"
    else
        echo "✗ FAIL: jq cannot parse JSON"
    fi
else
    echo "⚠️  SKIP: jq not available for testing"
fi

if [[ "$yq_installed" == true ]]; then
    echo "Testing yq functionality..."
    test_yaml='test: value'
    if echo "$test_yaml" | yq . >/dev/null 2>&1; then
        echo "✓ PASS: yq can parse YAML"
    else
        echo "✗ FAIL: yq cannot parse YAML"
    fi
else
    echo "⚠️  SKIP: yq not available for testing"
fi

echo

# Test 6: Test PATH setup logic
echo "Test 6: Test PATH setup logic"
echo "Functions would create ~/bin directory and add to PATH"
echo "Expected PATH modification: export PATH=~/bin:\$PATH"

# Check if ~/bin exists and is in PATH
if [[ -d ~/bin ]]; then
    echo "ℹ️  INFO: ~/bin directory exists"
    if echo "$PATH" | grep -q "$HOME/bin"; then
        echo "✓ INFO: ~/bin is already in PATH"
    else
        echo "⚠️  INFO: ~/bin exists but is not in PATH"
    fi
else
    echo "ℹ️  INFO: ~/bin directory does not exist (would be created by install functions)"
fi

echo
echo "=== install_jq() and install_yq() Test Completed ==="
echo
echo "NOTE: These tests do not actually install tools to avoid system modifications."
echo "To test actual installation, run install_jq or install_yq manually."
