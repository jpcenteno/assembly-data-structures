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
    {
        char * s = strClone("foo");
        s = strConcat(s, strClone("barbaz"));
        assert(strcmp(s, "foobarbaz") == 0);
        s = strConcat(s, strClone(""));
        assert(strcmp(s, "foobarbaz") == 0);
        s = strConcat(strClone(""), s);
        assert(strcmp(s, "foobarbaz") == 0);
        strDelete(s);
    }
    {

        char *a, *b, *c;

        a = strClone("perro_");
        b = strClone("loco");
        assert(strLen(a) == 6);
        assert(strLen(b) == 4);

        c = strConcat(a,b);
        assert(strCmp(c, "perro_loco") == 0);

        c = strConcat(c,strClone(""));
        assert(strCmp(c, "perro_loco") == 0);

        c = strConcat(strClone(""),c);
        assert(strCmp(c, "perro_loco") == 0);

        c = strConcat(c,c);
        assert(strCmp(c, "perro_locoperro_loco") == 0);

        strDelete(c);

    }

    // strDelete
    char* s3 = strClone("asdfg");
    strDelete(s3); // El test es que no leeakee memoria

    // strPrint
    {
        strPrint("mambo\n", pfile);
        strPrint("mango\n", pfile);
    }
    {
        strPrint("", pfile);
        strPrint("\n", pfile);
    }

    // strCmp
    {
        char* s1 = "aba";
        char* s2 = "aca";
        assert(strCmp(s1, s2) == 1);
        assert(strCmp(s2, s1) == -1);
        assert(strCmp(s1, s1) == 0);
        assert(strCmp(s2, s2) == 0);

        assert(strCmp("", s2) == 1);
        assert(strCmp("", "") == 0);
    }

    // char* strRange(char* a, uint32_t i, uint32_t f)
    {

        // Caso normal
        char* s1 = strRange( strClone("ABC"),  1,  1 );
        assert( strcmp( s1, "B" ) == 0 );
        strDelete(s1);

        // caso i>f => devuelve a
        char* s2 = strRange( strClone("ABC"), 10,  0);
        assert( strcmp( s2, "ABC" ) == 0 );
        strDelete(s2);

        // Caso strlen(a) < f => f=strlen(a)
        char * s3 = strRange( strClone("ABC"),  1, 10);
        assert( strcmp( s3, "BC")  == 0 );
        strDelete(s3);

        // caso strlen(a) <= i <= f, devuelve ""
        char * s4 = strRange( strClone("ABC"),  3, 10);
        assert( strcmp( s4, "" ) == 0 );
        strDelete(s4);

    }
    // Caso que fallo en tester
    {

        char* a = strClone("perro_loco");
        a = strRange(a, 10, 10);
        strDelete(a); // Deberia borrar el valor devuelto

    }

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
    {
        list_t* l = listNew();
        char* s1 = "bar";
        char* s2 = "baz";
        char* s3 = "foo";

        listAdd(l, s2, (funcCmp_t*) strCmp); // l = [baz]
        assert(l->first == l->last);
        assert(l->first->data == s2);
        assert(l->first->next == NULL);
        assert(l->first->prev == NULL);

        listAdd(l, s1, (funcCmp_t*) strCmp); // l = [bar, baz]
        assert(l->first->data == s1);
        assert(l->first->prev == NULL);
        assert(l->first->next == l->last);
        assert(l->last->data == s2);
        assert(l->last->prev == l->first);
        assert(l->last->next == NULL);

        listAdd(l, s3, (funcCmp_t*) strCmp); // l = [bar, baz, foo]
        assert(l->first->data == s1);
        assert(l->first->prev == NULL);
        assert(l->first->next == l->last->prev);
        assert(l->first->next->data == s2);
        assert(l->first->next->prev == l->first);
        assert(l->first->next->next == l->last);
        assert(l->last->data == s3);
        assert(l->last->prev == l->first->next);
        assert(l->last->next == NULL);

        listRemoveFirst(l, (funcDelete_t*) NULL); // no hace free porque son estaticas
        listRemoveFirst(l, (funcDelete_t*) NULL);
        listRemoveFirst(l, (funcDelete_t*) NULL);
        free(l);

    }
    // void listRemoveFirst(list_t* l, funcDelete_t* fd)
    {
        char *s1 = strcpy(malloc(4), "foo"); // en el heap
        char *s2 = strcpy(malloc(4), "bar");
        list_t* l = listNew();
        listAddLast(l, s1);
        listAddLast(l, s2); // l = ["foo", "bar"]

        listRemoveFirst(l, NULL); // l = ['bar'] y s1 no fue liberado
        assert(l->first == l->last);
        assert(l->first->data == s2);
        assert(l->first->prev == NULL);
        assert(l->first->next == NULL);

        listRemoveLast(l, free); // l = []
        assert(l->last == NULL);
        assert(l->first == NULL);

        free(s1); // Si fue liberado, segfaultea
        free(l);

    }
    { // Borrar de una lista vacia. Caso que fallaba en tester.c
        list_t* l1 = listNew();
        listRemoveFirst(l1, (funcDelete_t*)&strDelete);
        listDelete(l1, NULL);
    }
    // void listRemoveLast(list_t* l, funcDelete_t* fd)
    {

        char *s1 = strcpy(malloc(4), "foo");
        char *s2 = strcpy(malloc(4), "bar");
        list_t* l = listNew();
        listAddLast(l, s1);
        listAddLast(l, s2); // l = ["foo", "bar"]

        listRemoveLast(l, NULL); // l = ["foo"] y s2 no fue liberado
        assert(l->first == l->last);
        assert(l->first->data == s1);
        assert(l->first->prev == NULL);
        assert(l->first->next == NULL);

        listRemoveLast(l, free); // l = []
        assert(l->last == NULL);
        assert(l->first == NULL);

        free(s2); // Si s2 fue liberado, segfaultea
        free(l);

    }
    { // Borrar de una lista vacia. Caso que fallaba en tester.c
        l1 = listNew();
        listRemoveLast(l1, (funcDelete_t*)&strDelete);
        listDelete(l1, NULL);
    }
    // void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd)
    {

        char *s1 = strcpy(malloc(4), "foo");
        char *s2 = strcpy(malloc(4), "bar");
        char *s3 = strcpy(malloc(4), "baz");
        list_t* l = listNew();
        listAddLast(l, s1);
        listAddLast(l, s2); // l = ["foo", "bar"]
        listAddLast(l, s3); // l = ["foo", "bar", "baz"]

        listRemove(l, "bar", (funcCmp_t*) strCmp, (funcDelete_t*) strDelete); // l = [foo, baz]
        assert(l->first->data == s1);
        assert(l->first->prev == NULL);
        assert(l->first->next == l->last);
        assert(l->last->data == s3);
        assert(l->last->prev == l->first);
        assert(l->last->next == NULL);

        listRemove(l, "baz", (funcCmp_t*) strCmp, (funcDelete_t*) strDelete); // l = [foo]
        assert(l->first->data == s1);
        assert(l->first->prev == NULL);
        assert(l->first->next == NULL);
        assert(l->first == l->last);

        listRemove(l, "fiz", (funcCmp_t*) strCmp, (funcDelete_t*) strDelete); // l = [foo]
        assert(l->first->data == s1);
        assert(l->first->prev == NULL);
        assert(l->first->next == NULL);
        assert(l->first == l->last);

        listRemove(l, "foo", (funcCmp_t*) strCmp, NULL); // l = [] y s1 no fue liberado
        assert(l->first == NULL);
        assert(l->last  == NULL);

        listRemove(l, "foo", (funcCmp_t*) strCmp, (funcDelete_t*) strDelete); // l = []
        assert(l->first == NULL);
        assert(l->last  == NULL);

        strDelete(s1);
        free(l);
    }
    {
        char *s1 = strcpy(malloc(4), "foo");
        char *s2 = strcpy(malloc(4), "bar");
        char *s3 = strcpy(malloc(4), "foo");
        list_t* l = listNew();
        listAddLast(l, s1);
        listAddLast(l, s2); // l = ["foo", "bar"]
        listAddLast(l, s3); // l = ["foo", "bar", "foo"]

        listRemove(l, "foo", (funcCmp_t*) strCmp, (funcDelete_t*) strDelete); // l = [bar]
        assert(l->first == l->last);
        assert(l->first->data == s2);
        assert(l->first->next == NULL);
        assert(l->first->prev == NULL);

        listRemove(l, "bar", (funcCmp_t*) strCmp, (funcDelete_t*) strDelete); // l = []
        assert(l->first == NULL);
        assert(l->last  == NULL);

        free(l);

    }
    // void listDelete(list_t* l, funcDelete_t* fd)
    {
        list_t* l = listNew();
        listDelete(l, NULL);
    }
    {   // Caso sin borrar elementos

        char *s1 = strcpy(malloc(4), "foo");
        char *s2 = strcpy(malloc(4), "bar");
        char *s3 = strcpy(malloc(4), "foo");
        list_t* l = listNew();
        listAddLast(l, s1);
        listAddLast(l, s2); // l = ["foo", "bar"]
        listAddLast(l, s3); // l = ["foo", "bar", "foo"]

        listDelete(l, NULL);
        free(s1);
        free(s2);
        free(s3);

    }
    {

        char *s1 = strcpy(malloc(4), "foo");
        char *s2 = strcpy(malloc(4), "bar");
        char *s3 = strcpy(malloc(4), "foo");
        list_t* l = listNew();
        listAddLast(l, s1);
        listAddLast(l, s2); // l = ["foo", "bar"]
        listAddLast(l, s3); // l = ["foo", "bar", "foo"]

        listDelete(l, (funcDelete_t*) strDelete);

    }
    // void listPrint(list_t* l, FILE *pFile, funcPrint_t* fp)
    {
        list_t* l = listNew();
        listPrint(l, pfile, NULL);
        fprintf(pfile, "\n");
        listDelete(l, NULL);
    }
    {
        char *s1 = strcpy(malloc(4), "foo");
        char *s2 = strcpy(malloc(4), "bar");
        char *s3 = strcpy(malloc(4), "baz");
        list_t* l = listNew();
        listAddLast(l, s1);
        listAddLast(l, s2);
        listAddLast(l, s3); // l = ["foo", "bar", "baz"]

        listPrint(l, pfile, (funcPrint_t*) strPrint);
        fprintf(pfile, "\n");

        listDelete(l, (funcDelete_t*) strDelete);

    }
    // void listPrintReverse(list_t* l, FILE *pFile, funcPrint_t* fp)
    {
        list_t* l = listNew();
        listPrintReverse(l, pfile, NULL);
        fprintf(pfile, "\n");
        listDelete(l, NULL);
    }
    {
        char *s1 = strcpy(malloc(4), "foo");
        char *s2 = strcpy(malloc(4), "bar");
        char *s3 = strcpy(malloc(4), "baz");
        list_t* l = listNew();
        listAddLast(l, s1);
        listAddLast(l, s2);
        listAddLast(l, s3); // l = ["foo", "bar", "baz"]

        listPrintReverse(l, pfile, (funcPrint_t*) strPrint);
        fprintf(pfile, "\n");

        listDelete(l, (funcDelete_t*) strDelete);

    }
}

/** Verifica 'n->center'
 *
 * Si La estructura es incorrecta falla un assert. Crashea
 * Si la estructura es correcta y coincide con n->data devuelve el tamano de n->center
 */
int32_t aux_check_n3treeelement_center(n3treeElem_t* n, funcCmp_t* fc) {


    const listElem_t* last = n->center->last;

    listElem_t* e = n->center->first;
    listElem_t* prev = NULL; // Se usa para chequear e->prev
    int32_t counter = 0;
    while (e != NULL) {

        counter++;

        assert(fc(e->data, n->data) == 0);    // El dato es correcto
        assert(e->prev == prev);              // El enlace al nodo anterior es correcto
        assert(e->next != NULL || e == last); // Solo puede terminar si es coherente con center->last

        // Avanza al proximo nodo de la lista
        prev = e;
        e = e->next;

    }

    return counter;
}

void test_n3tree(FILE *pfile){

    // n3tree_t* n3treeNew();
    {
        n3tree_t* t = n3treeNew();
        assert(t->first == NULL);
        free(t);
    }
    // void n3treeAdd(n3tree_t* t, void* data, funcCmp_t* fc);
    {

        char *s1 = strcpy(malloc(2), "a");
        char *s2 = strcpy(malloc(2), "b");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        char *s5 = strcpy(malloc(2), "b");

        n3tree_t* t = n3treeNew();

        // Caso add nodo a tree vacio
        n3treeAdd(t, s2, (funcCmp_t*) strCmp);
        assert(t->first != NULL);
        assert(strCmp(t->first->data, s2) == 0); // raiz->data == s2
        assert(t->first->left == NULL);
        assert(aux_check_n3treeelement_center(t->first, (funcCmp_t*) strCmp) == 0);
        assert(t->first->right == NULL);

        // caso add varios elementos a nodo ya existente
        n3treeAdd(t, s4, (funcCmp_t*) strCmp);
        n3treeAdd(t, s5, (funcCmp_t*) strCmp);
        assert(t->first != NULL);
        assert(strCmp(t->first->data, s2) == 0); // raiz->data == s2
        assert(t->first->left == NULL);
        assert(aux_check_n3treeelement_center(t->first, (funcCmp_t*) strCmp) == 2);
        assert(t->first->right == NULL);

        // Caso add nodo a la izquierda de otro nodo
        n3treeAdd(t, s1, (funcCmp_t*) strCmp);
        assert(t->first != NULL);
        assert(strCmp(t->first->data, s2) == 0); // raiz->data == s2
        assert(aux_check_n3treeelement_center(t->first, (funcCmp_t*) strCmp) == 2);
        assert(t->first->right == NULL);
        assert(t->first->left != NULL);
        assert(strCmp(t->first->left->data, "a") == 0);
        assert(aux_check_n3treeelement_center(t->first->left, (funcCmp_t*) strCmp) == 0);
        assert(t->first->left->left == NULL);
        assert(t->first->left->right == NULL);

        // Caso add nodo a la derecha de otro nodo
        n3treeAdd(t, s3, (funcCmp_t*) strCmp);
        // Check puntero a raiz
        assert(t->first != NULL);                                                   // Existe nodo raiz
        // check raiz
        assert(strCmp(t->first->data, "b") == 0);                                   // raiz->data == "b"
        assert(aux_check_n3treeelement_center(t->first, (funcCmp_t*) strCmp) == 2); // La lista tiene 2 elems iguales a "b"
        assert(t->first->left  != NULL);                                            // Existe nodo izdo
        assert(t->first->right != NULL);                                            // Existe nodo dho
        // Check rama izda
        assert(strCmp(t->first->left->data, "a") == 0);                             // ramaizda->data == "a"
        assert(aux_check_n3treeelement_center(t->first->left, (funcCmp_t*) strCmp) == 0); // 0 elementos iguales a "a"
        assert(t->first->left->left  == NULL);                                      // no existe nodo izdo
        assert(t->first->left->right == NULL);                                      // no existe nodo dho
        // check rama dcha
        assert(strCmp(t->first->right->data, "c") == 0);                             // ramaizda->data == "c"
        assert(aux_check_n3treeelement_center(t->first->right, (funcCmp_t*) strCmp) == 0); // 0 elementos iguales a "c"
        assert(t->first->right->left  == NULL);                                      // no existe nodo izdo
        assert(t->first->right->right == NULL);                                      // no existe nodo dho

        // Limpieza

        listDelete(t->first->right->center, (funcDelete_t*) strDelete);
        strDelete(t->first->right->data);
        free(t->first->right);

        listDelete(t->first->left->center, (funcDelete_t*) strDelete);
        strDelete(t->first->left->data);
        free(t->first->left);

        listDelete(t->first->center, (funcDelete_t*) strDelete);
        free(t->first->data);
        free(t->first);
        free(t);

    }
    // void n3treeRemoveEq(n3tree_t* t, funcDelete_t* fd);
    // Recorre recursivamente todo el arbol, borrando en cada nodo todos
    // los elementos de su lista de datos iguales (center). Si fd no es
    // cero, utiliza la funci´ on para borrar los datos respectivamente.
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        char *s5 = strcpy(malloc(2), "b");
        char *s6 = strcpy(malloc(2), "c");
        char *s7 = strcpy(malloc(2), "c");

        n3tree_t* t = n3treeNew();

        n3treeAdd(t, s1, (funcCmp_t*) strCmp);
        n3treeAdd(t, s2, (funcCmp_t*) strCmp);
        n3treeAdd(t, s3, (funcCmp_t*) strCmp);
        n3treeAdd(t, s4, (funcCmp_t*) strCmp);
        n3treeAdd(t, s5, (funcCmp_t*) strCmp);
        n3treeAdd(t, s6, (funcCmp_t*) strCmp);
        n3treeAdd(t, s7, (funcCmp_t*) strCmp);
        /*          b,{b, b}
                    /       \
                   a,{}     c,{c,c} */

        n3treeRemoveEq(t, (funcDelete_t*) strDelete);
        /*          b,{}
                    /       \
                   a,{}     c,{} */
        assert(t->first != NULL);
        // Raiz
        assert(strcmp(t->first->data, "b") == 0);
        assert(aux_check_n3treeelement_center(t->first, (funcCmp_t*) strCmp) == 0);
        assert(t->first->left != NULL);
        assert(t->first->right != NULL);
        // Raiz->izda
        assert(strcmp(t->first->left->data, "a") == 0);
        assert(aux_check_n3treeelement_center(t->first->left, (funcCmp_t*) strCmp) == 0);
        assert(t->first->left->left  == NULL);
        assert(t->first->left->right == NULL);
        // Raiz->dha
        assert(strcmp(t->first->right->data, "c") == 0);
        assert(aux_check_n3treeelement_center(t->first->right, (funcCmp_t*) strCmp) == 0);
        assert(t->first->right->left  == NULL);
        assert(t->first->right->right == NULL);

        // Libero datos
        listDelete(t->first->center, NULL);
        listDelete(t->first->left->center, NULL);
        listDelete(t->first->right->center, NULL);
        strDelete(t->first->data);
        strDelete(t->first->left->data);
        strDelete(t->first->right->data);
        free(t->first->left);
        free(t->first->right);
        free(t->first);
        free(t);

    }
    { // Caso 2: fd == NULL

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        char *s5 = strcpy(malloc(2), "b");
        char *s6 = strcpy(malloc(2), "c");
        char *s7 = strcpy(malloc(2), "c");

        n3tree_t* t = n3treeNew();

        n3treeAdd(t, s1, (funcCmp_t*) strCmp);
        n3treeAdd(t, s2, (funcCmp_t*) strCmp);
        n3treeAdd(t, s3, (funcCmp_t*) strCmp);
        n3treeAdd(t, s4, (funcCmp_t*) strCmp);
        n3treeAdd(t, s5, (funcCmp_t*) strCmp);
        n3treeAdd(t, s6, (funcCmp_t*) strCmp);
        n3treeAdd(t, s7, (funcCmp_t*) strCmp);
        /*          b,{b, b}
                    /       \
                   a,{}     c,{c,c} */

        n3treeRemoveEq(t, NULL);
        /*          b,{}
                    /       \
                   a,{}     c,{} */
        assert(t->first != NULL);
        // Raiz
        assert(strcmp(t->first->data, "b") == 0);
        assert(aux_check_n3treeelement_center(t->first, (funcCmp_t*) strCmp) == 0);
        assert(t->first->left != NULL);
        assert(t->first->right != NULL);
        // Raiz->izda
        assert(strcmp(t->first->left->data, "a") == 0);
        assert(aux_check_n3treeelement_center(t->first->left, (funcCmp_t*) strCmp) == 0);
        assert(t->first->left->left  == NULL);
        assert(t->first->left->right == NULL);
        // Raiz->dha
        assert(strcmp(t->first->right->data, "c") == 0);
        assert(aux_check_n3treeelement_center(t->first->right, (funcCmp_t*) strCmp) == 0);
        assert(t->first->right->left  == NULL);
        assert(t->first->right->right == NULL);

        // Libero datos
        // Estas se pierden al borrar las listas
        free(s4);
        free(s5);
        free(s6);
        free(s7);
        listDelete(t->first->center, NULL);
        listDelete(t->first->left->center, NULL);
        listDelete(t->first->right->center, NULL);
        strDelete(t->first->data);
        strDelete(t->first->left->data);
        strDelete(t->first->right->data);
        free(t->first->left);
        free(t->first->right);
        free(t->first);
        free(t);

    }
    // void n3treeDelete(n3tree_t* t, funcDelete_t* fd);
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        char *s5 = strcpy(malloc(2), "b");
        char *s6 = strcpy(malloc(2), "c");
        char *s7 = strcpy(malloc(2), "c");
        n3tree_t* t = n3treeNew();
        n3treeAdd(t, s1, (funcCmp_t*) strCmp);
        n3treeAdd(t, s2, (funcCmp_t*) strCmp);
        n3treeAdd(t, s3, (funcCmp_t*) strCmp);
        n3treeAdd(t, s4, (funcCmp_t*) strCmp);
        n3treeAdd(t, s5, (funcCmp_t*) strCmp);
        n3treeAdd(t, s6, (funcCmp_t*) strCmp);
        n3treeAdd(t, s7, (funcCmp_t*) strCmp);
        /*          b,{b, b}
                    /       \
                   a,{}     c,{c,c} */

        n3treeDelete(t, (funcDelete_t*) strDelete); // El test es que no haya memleaks

    }
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        char *s5 = strcpy(malloc(2), "b");
        char *s6 = strcpy(malloc(2), "c");
        char *s7 = strcpy(malloc(2), "c");
        n3tree_t* t = n3treeNew();
        n3treeAdd(t, s1, (funcCmp_t*) strCmp);
        n3treeAdd(t, s2, (funcCmp_t*) strCmp);
        n3treeAdd(t, s3, (funcCmp_t*) strCmp);
        n3treeAdd(t, s4, (funcCmp_t*) strCmp);
        n3treeAdd(t, s5, (funcCmp_t*) strCmp);
        n3treeAdd(t, s6, (funcCmp_t*) strCmp);
        n3treeAdd(t, s7, (funcCmp_t*) strCmp);
        /*          b,{b, b}
                    /       \
                   a,{}     c,{c,c} */

        // El test es que no haya memleaks. Entre `n3treeDelete` y los free(sX)
        // se deberia limpiar la memoria
        n3treeDelete(t, NULL);
        free(s1);
        free(s2);
        free(s3);
        free(s4);
        free(s5);
        free(s6);
        free(s7);

    }
    // void n3treePrint(n3tree_t* t, FILE *pFile, funcPrint_t* fp);
    {
        n3tree_t* t = n3treeNew();
        n3treePrint(t, pfile, NULL);
        fprintf(pfile, "\n");
        n3treeDelete(t, NULL);
    }
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        char *s5 = strcpy(malloc(2), "b");
        char *s6 = strcpy(malloc(2), "c");
        char *s7 = strcpy(malloc(2), "c");
        n3tree_t* t = n3treeNew();
        n3treeAdd(t, s1, (funcCmp_t*) strCmp);
        n3treeAdd(t, s2, (funcCmp_t*) strCmp);
        n3treeAdd(t, s3, (funcCmp_t*) strCmp);
        n3treeAdd(t, s4, (funcCmp_t*) strCmp);
        n3treeAdd(t, s5, (funcCmp_t*) strCmp);
        n3treeAdd(t, s6, (funcCmp_t*) strCmp);
        n3treeAdd(t, s7, (funcCmp_t*) strCmp);

        /*          b,{b, b}
                    /       \
                   a,{}     c,{c,c} */

        n3treePrint(t, pfile, (funcPrint_t*) strPrint);
        fprintf(pfile, "\n");
        n3treeDelete(t, (funcDelete_t*) strDelete);

    }


}

void test_nTable(FILE *pfile){

    // nTable_t* nTableNew(uint32_t size)(31 Inst.)
    {

        uint32_t n = 9;
        nTable_t* t = nTableNew(n);

        assert(t->size == n);
        for ( uint32_t i = 0; i < n; ++i ) {
            assert(t->listArray[i]->first == NULL);
            assert(t->listArray[i]->last  == NULL);
        }

        // Libera memoria
        for ( uint32_t i = 0; i < n; ++i ) {
            free(t->listArray[i]);
        }
        free(t->listArray);
        free(t);

    }

    // void nTableAdd(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc)(9 Inst.)
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        char *s5 = strClone("hola mundo");
        char *s6 = strClone("chau gente");
        nTable_t* t = nTableNew(3);

        nTableAdd(t, 2, s1, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [b]}
        nTableAdd(t, 2, s2, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b]}
        nTableAdd(t, 2, s3, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b, c]}
        nTableAdd(t, 0, s4, (funcCmp_t*) strCmp); // {0: [b], 1: [], 2: [a, b, c]}

        assert(t->size == 3);
        assert(t->listArray != NULL);

        // Lista 0
        assert(t->listArray[0]->first == t->listArray[0]->last);
        assert(t->listArray[0]->first->data == s4);
        assert(t->listArray[0]->first->next == NULL);
        assert(t->listArray[0]->first->prev == NULL);

        // Lista 1
        assert(t->listArray[1]->first == NULL);
        assert(t->listArray[1]->last == NULL);

        // Lista 2
        // list_t
        assert(t->listArray[2]->first != NULL);
        assert(t->listArray[2]->last != NULL);
        assert(t->listArray[2]->last != t->listArray[2]->first);
        // listElem_t 1:
        assert(t->listArray[2]->first->data == s2);
        assert(t->listArray[2]->first->prev == NULL);
        // listElem_t 2:
        assert(t->listArray[2]->first->next->data == s1);
        assert(t->listArray[2]->first->next->prev == t->listArray[2]->first);
        assert(t->listArray[2]->first->next->next == t->listArray[2]->last);
        // listElem_t 3:
        assert(t->listArray[2]->first->next->next->data == s3);
        assert(t->listArray[2]->first->next->next->prev == t->listArray[2]->first->next);
        assert(t->listArray[2]->first->next->next->next == NULL);

        for ( int i = 0; i < 3; ++i) {
            listDelete(t->listArray[i], (funcDelete_t*) strDelete);
        }

        free(t->listArray);
        free(t);

        free(s5);
        free(s6);

    }
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        char *s5 = strClone("hola mundo");
        char *s6 = strClone("chau gente");
        nTable_t* t = nTableNew(3);

        nTableAdd(t, 2 + 3*5, s1, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [b]}
        nTableAdd(t, 2 + 3*3, s2, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b]}
        nTableAdd(t, 2 + 3*2, s3, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b, c]}
        nTableAdd(t, 0 + 3*0, s4, (funcCmp_t*) strCmp); // {0: [b], 1: [], 2: [a, b, c]}

        assert(t->size == 3);
        assert(t->listArray != NULL);

        // Lista 0
        assert(t->listArray[0]->first == t->listArray[0]->last);
        assert(t->listArray[0]->first->data == s4);
        assert(t->listArray[0]->first->next == NULL);
        assert(t->listArray[0]->first->prev == NULL);

        // Lista 1
        assert(t->listArray[1]->first == NULL);
        assert(t->listArray[1]->last == NULL);

        // Lista 2
        // list_t
        assert(t->listArray[2]->first != NULL);
        assert(t->listArray[2]->last != NULL);
        assert(t->listArray[2]->last != t->listArray[2]->first);
        // listElem_t 1:
        assert(t->listArray[2]->first->data == s2);
        assert(t->listArray[2]->first->prev == NULL);
        // listElem_t 2:
        assert(t->listArray[2]->first->next->data == s1);
        assert(t->listArray[2]->first->next->prev == t->listArray[2]->first);
        assert(t->listArray[2]->first->next->next == t->listArray[2]->last);
        // listElem_t 3:
        assert(t->listArray[2]->first->next->next->data == s3);
        assert(t->listArray[2]->first->next->next->prev == t->listArray[2]->first->next);
        assert(t->listArray[2]->first->next->next->next == NULL);

        for ( int i = 0; i < 3; ++i) {
            listDelete(t->listArray[i], (funcDelete_t*) strDelete);
        }

        free(t->listArray);
        free(t);

        free(s5);
        free(s6);

    }

    // void nTableRemoveSlot(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc,
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        nTable_t* t = nTableNew(3);
        nTableAdd(t, 2, s1, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [b]}
        nTableAdd(t, 2, s2, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b]}
        nTableAdd(t, 2, s3, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b, c]}
        nTableAdd(t, 0, s4, (funcCmp_t*) strCmp); // {0: [b], 1: [], 2: [a, b, c]}

        nTableRemoveSlot(t, 2, "b", (funcCmp_t*) strCmp, (funcDelete_t*) strDelete);

        assert(t->size == 3);
        assert(t->listArray != NULL);

        // Lista 0
        assert(t->listArray[0]->first == t->listArray[0]->last);
        assert(t->listArray[0]->first->data == s4);
        assert(t->listArray[0]->first->next == NULL);
        assert(t->listArray[0]->first->prev == NULL);

        // Lista 1
        assert(t->listArray[1]->first == NULL);
        assert(t->listArray[1]->last == NULL);

        // Lista 2
        // list_t
        assert(t->listArray[2]->first != NULL);
        assert(t->listArray[2]->last != NULL);
        assert(t->listArray[2]->last != t->listArray[2]->first);
        // listElem_t 0:
        assert(t->listArray[2]->first->data == s2); // a
        assert(t->listArray[2]->first->prev == NULL);
        assert(t->listArray[2]->first->next == t->listArray[2]->last);
        // listElem_t 1:
        assert(t->listArray[2]->last->data == s3); // b
        assert(t->listArray[2]->last->prev == t->listArray[2]->first);
        assert(t->listArray[2]->last->next == NULL);

        // Limpieza

        for (int i = 0; i < 3; ++i ) {
            listDelete(t->listArray[i], (funcDelete_t*) strDelete);
        }
        free(t->listArray);
        free(t);

    }
    // void nTableRemoveAll(nTable_t* t, void* data, funcCmp_t* fc, funcDelete_t* fd)
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        nTable_t* t = nTableNew(3);
        nTableAdd(t, 2, s1, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [b]}
        nTableAdd(t, 2, s2, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b]}
        nTableAdd(t, 2, s3, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b, c]}
        nTableAdd(t, 0, s4, (funcCmp_t*) strCmp); // {0: [b], 1: [], 2: [a, b, c]}

        nTableRemoveAll(t, "b", (funcCmp_t*) strCmp, (funcDelete_t*) strDelete);

        assert(t->size == 3);
        assert(t->listArray != NULL);

        // Lista 0
        assert(t->listArray[0]->first == NULL);
        assert(t->listArray[0]->last  == NULL);

        // Lista 1
        assert(t->listArray[1]->first == NULL);
        assert(t->listArray[1]->last  == NULL);

        // Lista 2
        // list_t
        assert(t->listArray[2]->first != NULL);
        assert(t->listArray[2]->last  != NULL);
        assert(t->listArray[2]->last  != t->listArray[2]->first);
        // listElem_t 0:
        assert(t->listArray[2]->first->data == s2); // a
        assert(t->listArray[2]->first->prev == NULL);
        assert(t->listArray[2]->first->next == t->listArray[2]->last);
        // listElem_t 1:
        assert(t->listArray[2]->last->data == s3); // b
        assert(t->listArray[2]->last->prev == t->listArray[2]->first);
        assert(t->listArray[2]->last->next == NULL);

        // Limpieza

        for (int i = 0; i < 3; ++i ) {
            listDelete(t->listArray[i], (funcDelete_t*) strDelete);
        }
        free(t->listArray);
        free(t);
    }

    // void nTableDeleteSlot(nTable_t* t, uint32_t slot, funcDelete_t* fd)(21 Inst.)
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        nTable_t* t = nTableNew(3);
        nTableAdd(t, 2, s1, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [b]}
        nTableAdd(t, 2, s2, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b]}
        nTableAdd(t, 2, s3, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b, c]}
        nTableAdd(t, 0, s4, (funcCmp_t*) strCmp); // {0: [b], 1: [], 2: [a, b, c]}

        nTableDeleteSlot(t, 2, (funcDelete_t*) strDelete);

        assert(t->size == 3);
        assert(t->listArray != NULL);

        // Lista 0
        assert(t->listArray[0]->first == t->listArray[0]->last);
        assert(t->listArray[0]->first->data == s4);
        assert(t->listArray[0]->first->next == NULL);
        assert(t->listArray[0]->first->prev == NULL);

        // Lista 1
        assert(t->listArray[1]->first == NULL);
        assert(t->listArray[1]->last == NULL);

        // Lista 2
        assert(t->listArray[2]->first == NULL);
        assert(t->listArray[2]->last == NULL);

        // Limpieza
        for (int i = 0; i < 3; ++i ) {
            listDelete(t->listArray[i], (funcDelete_t*) strDelete);
        }
        free(t->listArray);
        free(t);

    }
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        nTable_t* t = nTableNew(3);
        nTableAdd(t, 2, s1, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [b]}
        nTableAdd(t, 2, s2, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b]}
        nTableAdd(t, 2, s3, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b, c]}
        nTableAdd(t, 0, s4, (funcCmp_t*) strCmp); // {0: [b], 1: [], 2: [a, b, c]}

        nTableDeleteSlot(t, 2 + 3*4, (funcDelete_t*) strDelete);

        assert(t->size == 3);
        assert(t->listArray != NULL);

        // Lista 0
        assert(t->listArray[0]->first == t->listArray[0]->last);
        assert(t->listArray[0]->first->data == s4);
        assert(t->listArray[0]->first->next == NULL);
        assert(t->listArray[0]->first->prev == NULL);

        // Lista 1
        assert(t->listArray[1]->first == NULL);
        assert(t->listArray[1]->last == NULL);

        // Lista 2
        assert(t->listArray[2]->first == NULL);
        assert(t->listArray[2]->last == NULL);

        // Limpieza
        for (int i = 0; i < 3; ++i ) {
            listDelete(t->listArray[i], (funcDelete_t*) strDelete);
        }
        free(t->listArray);
        free(t);

    }

    // void nTableDeleteSlot(nTable_t* t, uint32_t slot, funcDelete_t* fd)
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        nTable_t* t = nTableNew(3);
        nTableAdd(t, 2, s1, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [b]}
        nTableAdd(t, 2, s2, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b]}
        nTableAdd(t, 2, s3, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b, c]}
        nTableAdd(t, 0, s4, (funcCmp_t*) strCmp); // {0: [b], 1: [], 2: [a, b, c]}

        nTableDelete(t, (funcDelete_t*) strDelete);
    }

    // void nTablePrint(nTable_t* t, FILE *pFile, funcPrint_t* fp)
    {

        char *s1 = strcpy(malloc(2), "b");
        char *s2 = strcpy(malloc(2), "a");
        char *s3 = strcpy(malloc(2), "c");
        char *s4 = strcpy(malloc(2), "b");
        nTable_t* t = nTableNew(3);
        nTableAdd(t, 2, s1, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [b]}
        nTableAdd(t, 2, s2, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b]}
        nTableAdd(t, 2, s3, (funcCmp_t*) strCmp); // {0: [],  1: [], 2: [a, b, c]}
        nTableAdd(t, 0, s4, (funcCmp_t*) strCmp); // {0: [b], 1: [], 2: [a, b, c]}

        nTablePrint(t, pfile, (funcPrint_t*) strPrint);
        nTableDelete(t, (funcDelete_t*) strDelete);
    }

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


