#!/usr/bin/env bash

# Test de la función mejorada has_tty_available()
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test de has_tty_available() Mejorada ==="
echo

# Test 1: Entorno actual
echo "1. Entorno actual:"
echo -n "   TTY disponible: "
if has_tty_available; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "2. Simulando CI/CD (debería retornar SI):"

# GitHub Actions
export GITHUB_ACTIONS=true
echo -n "   GitHub Actions: "
if has_tty_available; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

# GitLab CI
unset GITHUB_ACTIONS
export GITLAB_CI=true
echo -n "   GitLab CI: "
if has_tty_available; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

# Jenkins
unset GITLAB_CI
export JENKINS_URL="http://jenkins.local"
echo -n "   Jenkins: "
if has_tty_available; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

# CI genérico
unset JENKINS_URL
export CI=true
echo -n "   CI genérico: "
if has_tty_available; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "3. Terminales sin TTY (deberían retornar NO):"

# Terminal dumb
unset CI
export TERM="dumb"
echo -n "   Terminal dumb: "
if has_tty_available; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

# Terminal unknown
TERM="unknown"
echo -n "   Terminal unknown: "
if has_tty_available; then
    echo "$(text_success "SI")"
else
    echo "$(text_danger "NO")"
fi

echo
echo "4. Test de confirm_action en CI/CD:"

# Simular confirmación en CI/CD
export CI=true
echo -n "   confirm_action en CI (debería funcionar): "
if confirm_action "¿Continuar? [y/N]: " <<< "y"; then
    echo "$(text_success "Confirmado")"
else
    echo "$(text_danger "Cancelado")"
fi

echo
echo "5. Test de confirm_action con QUIET en CI/CD:"
export QUIET=true
echo -n "   confirm_action con QUIET en CI: "
if confirm_action "¿Continuar? [y/N]: " <<< "y"; then
    echo "$(text_success "Confirmado")"
else
    echo "$(text_danger "Error esperado (QUIET activado)")"
fi

# Limpiar variables
unset GITHUB_ACTIONS GITLAB_CI JENKINS_URL CI QUIET TERM

echo
echo "=== Test completado ==="
