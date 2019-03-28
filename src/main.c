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

    // strDelete
    char* s3 = strClone("asdfg");
    strDelete(s3); // El test es que no leeakee memoria

}

void test_n3tree(FILE *pfile){
    
}

void test_nTable(FILE *pfile){
    
}

int main (void){
    FILE *pfile = fopen("salida.main.propios.txt","w");
    test_string(pfile);
    test_n3tree(pfile);
    test_nTable(pfile);
    fclose(pfile);
    return 0;
}


