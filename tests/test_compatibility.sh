#!/usr/bin/env bash

# Test de compatibilidad para funciones refactorizadas
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Test de Compatibilidad de Funciones Refactorizadas ==="
echo

# Test 1: Funciones básicas de logging
echo "Test 1: Funciones básicas de logging"
info "Este es un mensaje de info"
debug "Este es un mensaje de debug"
warn "Este es un mensaje de warning"
error "Este es un mensaje de error"
success "Este es un mensaje de success"

echo
echo "Test 2: Verificar QUIET mode"
export QUIET=true
info "Este mensaje NO debería verse (QUIET=true)"
debug "Este mensaje NO debería verse (QUIET=true)"
warn "Este mensaje NO debería verse (QUIET=true)"
error "Este mensaje SÍ debería verse (error siempre se muestra)"
success "Este mensaje NO debería verse (QUIET=true)"
unset QUIET

echo
echo "Test 3: Múltiples parámetros"
info "Info con" "múltiples" "parámetros"
warn "Warning con" "varios" "argumentos"

echo
echo "Test 4: Compatibilidad con redirección"
info "Redirigido a stderr" 2>/dev/null
echo "Si no hay mensajes de info arriba, la redirección funcionó"

echo
echo "Test 5: Verificar que warning() ya no existe"
if type warning >/dev/null 2>&1; then
    echo "ERROR: warning() todavía existe (debería haber sido eliminada)"
else
    echo "OK: warning() fue eliminada correctamente"
fi

echo
echo "=== Test completado ==="
