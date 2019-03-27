# TP1

Joaquin Perez Centeno (699/16)

## Funciones a implementar

- [ ] `char* strClone(char* a)` (19 Inst.)
- [ ] `uint32_t strLen(char* a)` (7 Inst.)
- [ ] `int32_t strCmp(char* a, char* b)` (25 Inst.)
- [ ] `char* strConcat(char* a, char* b)` (42 Inst.)
- [ ] `void strDelete(char* a)` (1 Inst.)
- [ ] `void strPrint(char* a, FILE *pFile)` (7 Inst.)

- [ ] `list_t* listNew()` (7 Inst.)
- [ ] `void listAddFirst(list_t* l, void* data)` (21 Inst.)
- [ ] `void listAddLast(list_t* l, void* data)` (21 Inst.)
- [ ] `void listAdd(list_t* l, void* data, funcCmp_t* fc)` (54 Inst.)
- [ ] `void listRemoveFirst(list_t* l, funcDelete_t* fd)` (16 Inst.)
- [ ] `void listRemoveLast(list_t* l, funcDelete_t* fd)` (16 Inst.)
- [ ] `void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd)` (49 Inst.)

- [ ] `n3tree_t* n3treeNew()` (6 Inst.)
- [ ] `void n3treeAdd(n3tree_t* t, void* data, funcCmp_t* fc)` (47 Inst.)
- [ ] `void n3treeRemoveEq(n3tree_t* t, funcDelete_t* fd)` (29 Inst.)
- [ ] `void n3treeDelete(n3tree_t* t, funcDelete_t* fd)` (33 Inst.)
- [ ] `nTable_t* nTableNew(uint32_t size)` (31 Inst.)

- [ ] `nTable_t* nTableNew(uint32_t size)` (31 Inst.)
- [ ] `void nTableAdd(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc)` (9 Inst.)
- [ ] `void nTableRemoveSlot(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc, funcDelete_t* fd)` (11 Inst.)
- [ ] `void nTableDeleteSlot(nTable_t* t, uint32_t slot, funcDelete_t* fd)` (21 Inst.)

- [ ] `char* strRange(char* a, uint32_t i, uint32_t f)` (15 LOCs)
- [ ] `void listPrintReverse(list_t* l, FILE *pFile, funcPrint_t* fp)` (15 LOCs)
- [ ] `void n3treePrint(n3tree_t* t, FILE *pFile, funcPrint_t* fp)` (11 LOCs)
- [ ] `void nTableRemoveAll(nTable_t* t, void* data, funcCmp_t* fc, funcDelete_t* fd)` (2 LOCs)
