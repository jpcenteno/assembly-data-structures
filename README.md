# TP1

Joaquin Perez Centeno (699/16)

## Funciones a implementar

Funciones de `string`:
- [X] `char* strClone(char* a)` (19 Inst.)
- [X] `uint32_t strLen(char* a)` (7 Inst.)
- [X] `int32_t strCmp(char* a, char* b)` (25 Inst.)
- [X] `char* strConcat(char* a, char* b)` (42 Inst.)
- [X] `void strDelete(char* a)` (1 Inst.)
- [X] `void strPrint(char* a, FILE *pFile)` (7 Inst.)

Funciones de `list_t`:
- [X] `list_t* listNew()` (7 Inst.)
- [X] `void listAddFirst(list_t* l, void* data)` (21 Inst.)
- [X] `void listAddLast(list_t* l, void* data)` (21 Inst.)
- [X] `void listAdd(list_t* l, void* data, funcCmp_t* fc)` (54 Inst.)
- [X] `void listRemoveFirst(list_t* l, funcDelete_t* fd)` (16 Inst.)
- [X] `void listRemoveLast(list_t* l, funcDelete_t* fd)` (16 Inst.)
- [X] `void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd)` (49 Inst.)

Funciones de `n3tree_t`:
- [X] `n3tree_t* n3treeNew()` (6 Inst.)
- [X] `void n3treeAdd(n3tree_t* t, void* data, funcCmp_t* fc)` (47 Inst.)
- [X] `void n3treeRemoveEq(n3tree_t* t, funcDelete_t* fd)` (29 Inst.)
- [X] `void n3treeDelete(n3tree_t* t, funcDelete_t* fd)` (33 Inst.)
- [ ] `nTable_t* nTableNew(uint32_t size)` (31 Inst.)

Funciones de `nTable_t`:
- [ ] `nTable_t* nTableNew(uint32_t size)` (31 Inst.)
- [ ] `void nTableAdd(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc)` (9 Inst.)
- [ ] `void nTableRemoveSlot(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc, funcDelete_t* fd)` (11 Inst.)
- [ ] `void nTableDeleteSlot(nTable_t* t, uint32_t slot, funcDelete_t* fd)` (21 Inst.)

Funciones a implementar en `C`:
- [ ] `char* strRange(char* a, uint32_t i, uint32_t f)` (15 LOCs)
- [ ] `void listPrintReverse(list_t* l, FILE *pFile, funcPrint_t* fp)` (15 LOCs)
- [ ] `void n3treePrint(n3tree_t* t, FILE *pFile, funcPrint_t* fp)` (11 LOCs)
- [ ] `void nTableRemoveAll(nTable_t* t, void* data, funcCmp_t* fc, funcDelete_t* fd)` (2 LOCs)

## Changelog

### 2019/03/27

- Implementacion de `strLen`

#### Modificaciones a `runMain.sh`

`runMain.sh` fue modificado para automatizar otras partes de testeo.

- `salida.caso.propios.txt` fue renombrado a `salida.main.propios.txt` que me
  resulta mas obvio.
- `runMain.sh` corre otras partes del build y testeo, como hacer un diff entre
  los resultados del test y los resultados esperados.
- Se creo el archivo `salida.main.esperado.txt` para guardar los resultados
  esperados.

### 2019/03/28

- Implementacion de `strClone`
- Implementacion de `strDelete`
- Implementacion de `strPrint`
- Implementacion de `strConcat`
- 
### 2019/03/29

- Implementacion de `listNew`
- Implementacion de `listAddFirst`

### 2019/04/02

- Implementacion de `listRemoveLast`
- Implementacion de `strCmp`
- Implementacion de `listRemoveFirst`
- Implementacion de `listRemove`
- Implementacion de `listAdd`

### 2019/04/06

- Implementacion de `n3treeNew`

### 2019/04/09
- Implementacion de `n3treeRemoveEq`
- Implementacion de `n3treeDelete`
