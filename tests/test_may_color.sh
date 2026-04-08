#!/usr/bin/env bash

# Test de la función mejorada may_color()
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test de may_color() Mejorada ==="
echo

# Test 1: Terminal actual
echo "1. Terminal actual:"
echo "   TERM=$TERM"
echo "   TERM_PROGRAM=${TERM_PROGRAM:-no definido}"
if may_color; then
    echo "   Resultado: $(text_success "Soporta colores")"
else
    echo "   Resultado: $(text_danger "No soporta colores")"
fi

echo
echo "2. Simulando terminales modernos:"

# iTerm
TERM_PROGRAM="iTerm.app" TERM="xterm-256color"
echo -n "   iTerm.app: "
if may_color; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

# Warp
TERM_PROGRAM="warp" TERM="xterm-256color"
echo -n "   Warp: "
if may_color; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

# WezTerm
TERM_PROGRAM="wezterm" TERM="xterm-256color"
echo -n "   WezTerm: "
if may_color; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

# VS Code
TERM_PROGRAM="vscode" TERM="xterm-256color"
echo -n "   VS Code: "
if may_color; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "3. Simulando CI/CD:"

# GitHub Actions
unset TERM_PROGRAM TERM
export GITHUB_ACTIONS=true
echo -n "   GitHub Actions: "
if may_color; then
    echo "$(text_success "SI (si es TTY)")"
else
    echo "$(text_danger "NO")"
fi

# GitLab CI
unset GITHUB_ACTIONS
export GITLAB_CI=true
echo -n "   GitLab CI: "
if may_color; then
    echo "$(text_success "SI (si es TTY)")"
else
    echo "$(text_danger "NO")"
fi

# Jenkins
unset GITLAB_CI
export JENKINS_URL="http://jenkins.local"
echo -n "   Jenkins: "
if may_color; then
    echo "$(text_success "SI (si es TTY)")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "4. Terminales sin color:"

# Dumb terminal
unset JENKINS_URL
TERM="dumb"
echo -n "   Terminal dumb: "
if may_color; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

# Linux console
TERM="linux"
echo -n "   Linux console: "
if may_color; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "5. Variable NO_COLOR:"
export TERM="xterm-256color"
export NO_COLOR=1
echo -n "   Con NO_COLOR=1: "
if may_color; then
    echo "$(text_success "Permite colores (manejo interno)")"
else
    echo "$(text_danger "Bloquea colores")"
fi

# Limpiar variables
unset TERM_PROGRAM GITHUB_ACTIONS GITLAB_CI JENKINS_URL NO_COLOR

echo
echo "=== Test completado ==="
