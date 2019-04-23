#include "lib.h"

void _aux_print_ptr(void* data, FILE* pFile) {
    fprintf(pFile, "%p", data);
}

/** STRING **/

#define MIN(x, y) ((x < y) ? x : y)

char* _aux_new_str_vacia_en_heap() {
        char * out = malloc(1);
        out[0] = 0;
        return out;
}

char* strRange(char* a, uint32_t i, uint32_t f) {

    // Casos triviales
    if (f < i)          return a;
    if (strlen(a) <= i) {
        strDelete(a);
        return _aux_new_str_vacia_en_heap();
    }

    f = MIN(strlen(a) - 1, f); // Si f > strlen(a), f = strlen(a) - 1

    char * out = malloc(f - i + 2);
    for (uint32_t k = 0; k <= f - i; ++k) {
        out[k] = a[i + k];
    }

    out[f - i + 1] = 0; // NUL terminator

    // Libera 'a' porque al devolver el mismo puntero a 'a' en el caso trivial,
    // no se puede saber si se libero o no la string de entrada.
    strDelete(a);

    return out;

}

/** Lista **/

void listPrintReverse(list_t* l, FILE *pFile, funcPrint_t* fp) {

    if (!fp) fp = (funcPrint_t*) _aux_print_ptr;

    fprintf(pFile, "[");

    listElem_t* e = l->last;
    while(e) {

        fp(e->data, pFile);
        e = e->prev;
        if (e) fprintf(pFile, ",");

    }

    fprintf(pFile, "]");
}

/** n3tree **/

void n3treePrintElement(n3treeElem_t* t, FILE *pFile, funcPrint_t* fp) {

    fp(t->data, pFile);
    if (t->center->first) {
        listPrint(t->center, pFile, fp);
    }


}

void n3treePrintAux(n3treeElem_t* e, FILE *pFile, funcPrint_t* fp) {
    if (!e) return; // Caso base

    n3treePrintAux(e->left, pFile, fp);
    if (e->left) { fprintf(pFile, " "); }
    n3treePrintElement(e, pFile, fp);
    if (e->right) { fprintf(pFile, " "); }
    n3treePrintAux(e->right, pFile, fp);
}

void n3treePrint(n3tree_t* t, FILE *pFile, funcPrint_t* fp) {

    fprintf(pFile, "<<");

    if (t->first) {

        fprintf(pFile, " ");
        n3treePrintAux(t->first, pFile, fp);
        fprintf(pFile, " ");

    } else {

        fprintf(pFile, " ");

    }

    fprintf(pFile, ">>");

}

/** nTable **/

void nTableRemoveAll(nTable_t* t, void* data, funcCmp_t* fc, funcDelete_t* fd) {

    for ( uint32_t i = 0; i < t->size; ++i ) {
        nTableRemoveSlot(t, i, data, fc, fd);
    }

}

void nTablePrint(nTable_t* t, FILE *pFile, funcPrint_t* fp) {

    if (!fp) fp = (funcPrint_t*) _aux_print_ptr;

    for ( uint32_t i = 0; i < t->size; ++i ) {
        fprintf(pFile, "%d = ", i);
        listPrint(t->listArray[i], pFile, (funcPrint_t*) fp);
        fprintf(pFile, "\n");
    }
}
