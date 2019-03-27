#!/usr/bin/env bash
reset

command -v valgrind > /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: No se encuentra valgrind."
  exit 1
fi

# == Compila ===================================================================
echo "** Corriendo Make..."
make main
if [ $? -ne 0 ]; then
  echo "ERROR: Error de compilacion."
  exit 1
fi

# == Chequea Leaks de memoria ==================================================
echo "** Corriendo Valgrind..."
valgrind --show-reachable=yes --leak-check=full --error-exitcode=1 ./main
if [ $? -ne 0 ]; then
  echo "  ** Error de memoria"
  exit 1
fi

# == Chequea diferencias entre los resultados mios y los esperados ============

DIFFER="diff -d"
TEST_OUT="salida.main.propios.txt"
TEST_OUT_EXPECTED="salida.main.esperado.txt"

echo ""
echo "** Corriendo diferencias..."

$DIFFER "$TEST_OUT" "$TEST_OUT_EXPECTED" > /tmp/diff_main
if [ $? -ne 0 ]; then
  echo "** Discrepancia en los casos de prueba"
  cat /tmp/diff_main
  exit 1
fi

echo "** Tests ok!!"
