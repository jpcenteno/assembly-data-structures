#include "lib.h"

/** STRING **/

#define MIN(x, y) ((x < y) ? x : y)

char* strRange(char* a, uint32_t i, uint32_t f) {

    // Casos triviales
    if (f < i)          return a;
    if (strlen(a) <= i) return "";

    f = MIN(strlen(a) - 1, f); // Si f > strlen(a), f = strlen(a) - 1

    char * out = malloc(f - i + 2);
    for (uint32_t k = 0; k <= f - i; ++k) {
        out[k] = a[i + k];
    }

    out[f - i + 1] = 0; // NUL terminator

    // Libera 'a' porque al devolver el mismo puntero a 'a' en el caso trivial,
    // no se puede saber si se libero o no la string de entrada.
    //free(a);

    return out;

}

/** Lista **/

void listPrintReverse(list_t* l, FILE *pFile, funcPrint_t* fp) {

}

/** n3tree **/

void n3treePrintAux(n3treeElem_t** t, FILE *pFile, funcPrint_t* fp) {

}

void n3treePrint(n3tree_t* t, FILE *pFile, funcPrint_t* fp) {

}

/** nTable **/

void nTableRemoveAll(nTable_t* t, void* data, funcCmp_t* fc, funcDelete_t* fd) {

    for ( uint32_t i = 0; i < t->size; ++i ) {
        nTableRemoveSlot(t, i, data, fc, fd);
    }

}

void _aux_print_ptr(void* data, FILE* pFile) {
    fprintf(pFile, "%p", data);
}
void nTablePrint(nTable_t* t, FILE *pFile, funcPrint_t* fp) {

    if (!fp) fp = (funcPrint_t*) _aux_print_ptr;

    for ( uint32_t i = 0; i < t->size; ++i ) {
        fprintf(pFile, "%d = ", i);
        listPrint(t->listArray[i], pFile, (funcPrint_t*) fp);
        fprintf(pFile, "\n");
    }
}
