#!/usr/bin/env bash

# Demo de uso de spinners
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Demo de Spinners ==="
echo

# Demo 1: Uso básico con run_with_spinner
echo "1. Uso automático con run_with_spinner():"
run_with_spinner "sleep 3" "Descargando archivo..." "ascii"

echo
echo "2. Spinner Unicode:"
run_with_spinner "sleep 2" "Procesando datos..." "unicode"

echo
echo "3. Spinner de puntos:"
run_with_spinner "sleep 2" "Conectando al servidor..." "dots"

echo
echo "4. Uso manual (control total):"
echo "   Iniciando proceso largo..."
sleep 5 &
PID=$!
spinner $PID
success "¡Proceso completado!"

echo
echo "5. Comando que falla (demo de manejo de errores):"
run_with_spinner "sleep 1 && false" "Intentando operación fallida..."

echo
echo "6. Barra de progreso manual:"
for i in {1..10}; do
    progress_bar $i 10
    sleep 0.3
done

echo
echo "=== Demo completada ==="
