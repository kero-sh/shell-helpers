#!/usr/bin/env bash

# Test for the improved has_tty_available() function
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test Enhanced has_tty_available() ==="
echo

# Test 1: Current environment
echo "1. Current environment:"
echo -n "   TTY available: "
if has_tty_available; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "2. Simulating CI/CD (should return YES):"

# GitHub Actions
export GITHUB_ACTIONS=true
echo -n "   GitHub Actions: "
if has_tty_available; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

# GitLab CI
unset GITHUB_ACTIONS
export GITLAB_CI=true
echo -n "   GitLab CI: "
if has_tty_available; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

# Jenkins
unset GITLAB_CI
export JENKINS_URL="http://jenkins.local"
echo -n "   Jenkins: "
if has_tty_available; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

# Generic CI
unset JENKINS_URL
export CI=true
echo -n "   Generic CI: "
if has_tty_available; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "3. Non-TTY terminals (should return NO):"

# Dumb terminal
unset CI
export TERM="dumb"
echo -n "   Terminal dumb: "
if has_tty_available; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

# Terminal unknown
TERM="unknown"
echo -n "   Terminal unknown: "
if has_tty_available; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "4. Test confirm_action in CI/CD:"

# Simulate confirmation in CI/CD
export CI=true
echo -n "   confirm_action in CI (should work): "
if confirm_action "Continue? [y/N]: " <<< "y"; then
    echo "$(text_success "Confirmed")"
else
    echo "$(text_danger "Cancelled")"
fi

echo
echo "5. Test confirm_action with QUIET in CI/CD:"
export QUIET=true
echo -n "   confirm_action with QUIET in CI: "
if confirm_action "Continue? [y/N]: " <<< "y"; then
    echo "$(text_success "Confirmed")"
else
    echo "$(text_danger "Expected error (QUIET enabled)")"
fi

# Clean variables
unset GITHUB_ACTIONS GITLAB_CI JENKINS_URL CI QUIET TERM

echo
echo "=== Test Completed ==="
