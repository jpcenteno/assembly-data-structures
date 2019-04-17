#!/usr/bin/env bash
reset

echo " "
echo "**Compilando"

make tester
if [ $? -ne 0 ]; then
  echo "  **Error de compilacion"
  exit 1
fi

echo " "
echo "**Corriendo Valgrind"

command -v valgrind > /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: No se encuentra valgrind."
  exit 1
fi

valgrind --show-reachable=yes --leak-check=full --error-exitcode=1 ./tester
if [ $? -ne 0 ]; then
  echo "  **Error de memoria"
  exit 1
fi

echo " "
echo "**Corriendo diferencias con la catedra"

DIFFER="diff -d"
ERRORDIFF=0

$DIFFER salida.caso1.txt salida.caso1.catedra.txt > /tmp/diff1
if [ $? -ne 0 ]; then
  echo "  **Discrepancia en el caso 1"
  ERRORDIFF=1
fi

$DIFFER salida.caso2.txt salida.caso2.catedra.txt > /tmp/diff2
if [ $? -ne 0 ]; then
  echo "  **Discrepancia en el caso 2"
  ERRORDIFF=1
fi

$DIFFER salida.caso3.txt salida.caso3.catedra.txt > /tmp/diff3
if [ $? -ne 0 ]; then
  echo "  **Discrepancia en el caso 3"
  ERRORDIFF=1
fi

echo " "
if [ $ERRORDIFF -eq 0 ]; then
  echo "**Todos los tests pasan"
fi
echo " "
