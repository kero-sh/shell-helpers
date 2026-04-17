#!/usr/bin/env bash

# Test for the improved may_color() function
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test Enhanced may_color() ==="
echo

# Test 1: Current terminal
echo "1. Current terminal:"
echo "   TERM=$TERM"
echo "   TERM_PROGRAM=${TERM_PROGRAM:-not defined}"
if may_color; then
    echo "   Result: $(text_success "Supports colors")"
else
    echo "   Result: $(text_danger "Does not support colors")"
fi

echo
echo "2. Simulating modern terminals:"

# iTerm
TERM_PROGRAM="iTerm.app" TERM="xterm-256color"
echo -n "   iTerm.app: "
if may_color; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

# Warp
TERM_PROGRAM="warp" TERM="xterm-256color"
echo -n "   Warp: "
if may_color; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

# WezTerm
TERM_PROGRAM="wezterm" TERM="xterm-256color"
echo -n "   WezTerm: "
if may_color; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

# VS Code
TERM_PROGRAM="vscode" TERM="xterm-256color"
echo -n "   VS Code: "
if may_color; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "3. Simulating CI/CD:"

# GitHub Actions
unset TERM_PROGRAM TERM
export GITHUB_ACTIONS=true
echo -n "   GitHub Actions: "
if may_color; then
    echo "$(text_success "YES (if TTY)")"
else
    echo "$(text_danger "NO")"
fi

# GitLab CI
unset GITHUB_ACTIONS
export GITLAB_CI=true
echo -n "   GitLab CI: "
if may_color; then
    echo "$(text_success "YES (if TTY)")"
else
    echo "$(text_danger "NO")"
fi

# Jenkins
unset GITLAB_CI
export JENKINS_URL="http://jenkins.local"
echo -n "   Jenkins: "
if may_color; then
    echo "$(text_success "YES (if TTY)")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "4. Non-color terminals:"

# Dumb terminal
unset JENKINS_URL
TERM="dumb"
echo -n "   Terminal dumb: "
if may_color; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

# Linux console
TERM="linux"
echo -n "   Linux console: "
if may_color; then
    echo "$(text_success "YES")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "5. NO_COLOR variable:"
export TERM="xterm-256color"
export NO_COLOR=1
echo -n "   With NO_COLOR=1: "
if may_color; then
    echo "$(text_success "Allows colors (internal handling)")"
else
    echo "$(text_danger "Blocks colors")"
fi

# Clean variables
unset TERM_PROGRAM GITHUB_ACTIONS GITLAB_CI JENKINS_URL NO_COLOR

echo
echo "=== Test Completed ==="
