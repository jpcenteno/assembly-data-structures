#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_string(FILE *pfile){
    fprintf(pfile, "test_string:\n");

    // strLen:
    fprintf(pfile, "strLen(\"gato\") = %d\n", strLen("gato"));
    fprintf(pfile, "strLen(\"abc\") = %d\n", strLen("abc"));
    fprintf(pfile, "strLen(\"\") = %d\n", strLen(""));

    // strclone
    char* s1 = "furfaro";
    char* s2 = strClone(s1);
    assert(strcmp(s1, s2) == 0);
    assert(s1 != s2);
    free(s2);

    // strConcat
    char* s4 = "foo";
    char* s5 = "barbaz";
    char* s6 = strConcat(s4, s5);
    assert(strcmp(s6, "foobarbaz") == 0);
    char* s7 = strConcat("", "");
    assert(strcmp(s7, "") == 0);
    char* s8 = strConcat(s6, s4);
    assert(strcmp(s8, "foobarbazfoo") == 0);
    free(s6);
    free(s7);
    free(s8);

    // strDelete
    char* s3 = strClone("asdfg");
    strDelete(s3); // El test es que no leeakee memoria

    // strPrint
    strPrint("mambo\n", pfile);
    strPrint("mango\n", pfile);

}

void test_list(FILE *pfile){

    // list_t* listNew()
    list_t* l1 = listNew();
    assert(l1->first == NULL);
    assert(l1->last  == NULL);
    free(l1);

    // void listAddFirst(list_t* l, void* data)
    int datum1 = 42;
    int datum2 = 123;
    list_t* l2 = listNew();
    listAddFirst(l2, &datum1);
    // Como tiene 1 solo elem tiene q ser el first y el last
    assert(l2->first == l2->last);
    assert(l2->first != NULL);
    assert(l2->first->data == &datum1); // Dato es correcto
    // Lista con 2 elementos
    listAddFirst(l2, &datum2);
    assert(l2->first != l2->last); // check list_t
    assert(l2->first->data == &datum2); // Check 1er elem
    assert(l2->first->prev == NULL);
    assert(l2->first->next == l2->last);
    assert(l2->last->data == &datum1); // Check 2do elem
    assert(l2->last->prev == l2->first);
    assert(l2->last->next == NULL);
    free(l2->first); // Libera memoria
    free(l2->last);
    free(l2);

    // void listAddLast(list_t* l, void* data)
    {
        int datum1 = 42;
        int datum2 = 123;
        list_t* l = listNew();

        listAddLast(l, &datum1);            // Lista debe ser ahora [42]
        assert(l->first != NULL);           // Existe ese elemento
        assert(l->first = l->last);         // Es primero y ultimo
        assert(l->first->data == &datum1);  // El dato es correcto
        assert(l->first->next == NULL);     // No tiene next en la cadena
        assert(l->first->prev == NULL);     // No tiene prev en la cadena

        listAddLast(l, &datum2);            // l = [42, 123]
        assert(l->first->data == &datum1);  // l[0] == 42
        assert(l->last->data == &datum2);   // l[1] == 123
        assert(l->first->prev == NULL);
        assert(l->last->next == NULL);
        assert(l->first->next == l->last);
        assert(l->last->prev == l->first);

        free(l->first);
        free(l->last);
        free(l);

    }

    // void listAdd(list_t* l, void* data, funcCmp_t* fc)
    // void listRemoveFirst(list_t* l, funcDelete_t* fd)
    // void listRemoveLast(list_t* l, funcDelete_t* fd)
    // void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd)
}

void test_n3tree(FILE *pfile){
    
}

void test_nTable(FILE *pfile){
    
}

int main (void){
    FILE *pfile = fopen("salida.main.propios.txt","w");
    test_string(pfile);
    test_list(pfile);
    test_n3tree(pfile);
    test_nTable(pfile);
    fclose(pfile);
    return 0;
}


