#!/usr/bin/env bash
# shellcheck disable=SC1091

# Spinner usage demo
source "$(dirname "$0")/../libs/helpers.sh"

echo "=== Spinner Demo ==="
echo

# Demo 1: Basic usage with run_with_spinner
echo "1. Automatic usage with run_with_spinner():"
run_with_spinner "sleep 3" "Downloading file..." "ascii"

echo
echo "2. Unicode Spinner:"
run_with_spinner "sleep 2" "Processing data..." "unicode"

echo
echo "3. Dots Spinner:"
run_with_spinner "sleep 2" "Connecting to server..." "dots"

echo
echo "4. Manual usage (full control):"
echo "   Starting long process..."
sleep 5 &
PID=$!
spinner $PID
success "Process completed!"

echo
echo "5. Failing command (error handling demo):"
if run_with_spinner "sleep 1 && false" "Attempting failed operation..." 2>/dev/null; then
    echo "Command succeeded (unexpected)"
else
    echo "Command failed as expected"
fi

echo
echo "6. Manual progress bar:"
for i in {1..10}; do
    progress_bar "$i" 10
    sleep 0.3
done

echo
echo "=== Demo Completed ==="
