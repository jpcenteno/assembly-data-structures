#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <unistd.h>

/* String */

char* strClone(char* a);
uint32_t strLen(char* a);
int32_t strCmp(char* a, char* b);
char* strConcat(char* a, char* b);
char* strRange(char* a, uint32_t i, uint32_t f);
void strDelete(char* a);
void strPrint(char* a, FILE *pFile);

/* List */

typedef struct s_list{
    struct s_listElem *first; // 8 Bytes => offset = 0
    struct s_listElem *last;  // 8 Bytes => offset = 8
} list_t;

typedef struct s_listElem{
    void *data;              // 8 Bytes => offset = 0
    struct s_listElem *next; // 8 Bytes => offset = 8
    struct s_listElem *prev; // 8 Bytes => offset = 16
} listElem_t;


typedef void (funcDelete_t)(void*);
typedef void (funcPrint_t)(void*, FILE *pFile);
typedef int32_t (funcCmp_t)(void*, void*);

list_t* listNew();
void listAddFirst(list_t* l, void* data);
void listAddLast(list_t* l, void* data);
void listAdd(list_t* l, void* data, funcCmp_t* fc);
void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd);
void listRemoveFirst(list_t* l, funcDelete_t* fd);
void listRemoveLast(list_t* l, funcDelete_t* fd);
void listDelete(list_t* l, funcDelete_t* fd);
void listPrint(list_t* l, FILE *pFile, funcPrint_t* fp);
void listPrintReverse(list_t* l, FILE *pFile, funcPrint_t* fp);

/** n3tree **/

typedef struct s_n3tree{
    struct s_n3treeElem *first;
} n3tree_t;

typedef struct s_n3treeElem{
    void* data;                 // 8 B, offset = 0
    struct s_n3treeElem *left;  // 8 B, offset = 8
    struct s_list *center;      // 8 B, offset = 16
    struct s_n3treeElem *right; // 9 B, offset = 24
} n3treeElem_t; // size = 32 B

n3tree_t* n3treeNew();
void n3treeAdd(n3tree_t* t, void* data, funcCmp_t* fc);
void n3treeRemoveEq(n3tree_t* t, funcDelete_t* fd);
void n3treeDelete(n3tree_t* t, funcDelete_t* fd);
void n3treePrint(n3tree_t* t, FILE *pFile, funcPrint_t* fp);

/** nTable **/

typedef struct s_nTable{
    struct s_list **listArray;
    uint32_t size;
} nTable_t;

nTable_t* nTableNew(uint32_t size);
void nTableAdd(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc);
void nTableRemoveSlot(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc, funcDelete_t* fd);
void nTableRemoveAll(nTable_t* t, void* data, funcCmp_t* fc, funcDelete_t* fd);
void nTableDeleteSlot(nTable_t* t, uint32_t slot, funcDelete_t* fd);
void nTableDelete(nTable_t* t, funcDelete_t* fd);
void nTablePrint(nTable_t* t, FILE *pFile, funcPrint_t* fp);

