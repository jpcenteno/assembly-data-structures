#include "lib.h"

/** STRING **/

char* strRange(char* a, uint32_t i, uint32_t f) {

    return 0;
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
