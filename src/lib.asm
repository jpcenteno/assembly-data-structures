BITS 64

%define NULL 0 ; nullptr

; Offsets list_t
%define LIST_OFF_FIRST 0
%define LIST_OFF_LAST  8
%define LIST_SIZE      16

; Offsets listElem_t
%define LISTELEM_OFF_DATA 0
%define LISTELEM_OFF_NEXT 8
%define LISTELEM_OFF_PREV 16
%define LISTELEM_SIZE     24

; Offsets n3tree_t
%define N3TREE_OFF_FIRST 0
%define N3TREE_SIZE 8

; Offsets n3treeElem_t
%define N3TREEELEM_OFF_DATA   0
%define N3TREEELEM_OFF_LEFT   8
%define N3TREEELEM_OFF_CENTER 16
%define N3TREEELEM_OFF_RIGHT  24
%define N3TREEELEM_SIZE       32

; Offsets nTable_t
%define NTABLE_OFF_LISTARRAY 0
%define NTABLE_OFF_SIZE      8
%define SIZE_NTABLE          16

%define SIZE_PTR             8


section .rodata

  listPrint_bracket_open:  DB "[", 0
  listPrint_comma:         DB ",", 0
  listPrint_bracket_close: DB "]", 0
  listPrint_ptr:           DB "%p", 0

  strPrint_formatter:      DB "%s", 0
  strPrint_null:           DB "NULL", 0


section .text

extern malloc
extern free
extern fprintf

global strLen
global strClone
global strCmp
global strConcat
global strDelete
global strPrint
global listNew
global listAddFirst
global listAddLast
global listAdd
global listRemove
global listRemoveFirst
global listRemoveLast
global listDelete
global listPrint
global n3treeNew
global n3treeAdd
global n3treeRemoveEq
global n3treeDelete
global nTableNew
global nTableAdd
global nTableRemoveSlot
global nTableDeleteSlot
global nTableDelete

; uint32_t strLen(char* a)
; EAX             RDI
strLen:
    push rbp
    mov rbp, rsp

    xor rax, rax  ; <- contador = 0

  .loop:
    mov dl, [rdi] ; Leo 1 char de `a`
    cmp dl, 0     ; Es el caracter nulo?
    jz .end       ; Si es nulo deja de sumar
    inc eax
    inc rdi
    jmp .loop

  .end:
    pop rbp
    ret

; char* strClone(char* a);
; RAX            RDI
strClone:
    push rbp
    mov rbp, rsp

    ; Obtengo longitud de `a`
    push rdi    ; Preservo `a`
    sub rsp, 8  ; Balanceo stack para hacer el `call`
    call strLen ; `eax = strLen(a)`

    ; Hago malloc de `strLen(a) + 1` Bytes
    inc eax      ; `eax = strLen(a) + 1`
    mov edi, eax ; Pone `strLen(a) + 1` como primer parametro.
    call malloc  ; Pide `strLen(a) + 1` Bytes

    ; Recupero `a`
    add rsp, 8
    pop rdi

    mov rsi, rax ; preservo rax

    ; copio char x char hasta llegar al char nulo
  .loop:
    mov dl, [rdi] ; Leo 1 char de la memoria
    mov [rsi], dl ; Lo escribo en la str destino
    inc rdi
    inc rsi
    cmp dl, 0
    jnz .loop


    pop rbp
    ret

strCmp:
    push rbp
    mov rbp, rsp

  .loop:

    mov dl, [rsi]
    cmp [rdi], dl
    jl .ret_lt                  ; a < b
    jg .ret_gt                  ; a > b

    cmp BYTE [rdi], 0           ; null terminator?
    je .ret_eq                  ; Ambas terminaron iguales

    inc rdi                     ; Proximo char `a`
    inc rsi                     ; Proximo char `b`
    jmp .loop                   ; Vuelve a comparar


  .ret_lt:                      ; a < b
    mov eax, 1                  ; Return 1
    jmp .end                    ; Fin

  .ret_gt:                      ; a > b
    mov eax, -1                 ; return -1
    jmp .end                    ; Fin

  .ret_eq:                      ; a == b
    xor eax, eax                ; Return 0

  .end:
    pop rbp
    ret


; char* strConcat(char* a, char* b);
; RAX             RDI      RSI
strConcat:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    sub rsp, 8

    ; preservo parametros
    mov r12, rdi                        ; r12 = a
    mov r13, rsi                        ; r13 = b


    ; strlen(a)
                        ; rdi = a (1er param)
    call strLen         ; eax = strlen(a);
    mov r14, rax        ; preservo rax = strlen(a)

    ; strlen(b)
    mov rdi, r13        ; rdi = b (1er param)
    call strLen         ; eax = strlen(b)

    ; malloc( strlen(a) + strlen(b) + 1 )
    mov rdi, r14        ; rdi = strlen(a)
    add rdi, rax        ; rdi = strlen(a) + strlen(b)
    inc rdi             ; rdi = strlen(a) + strlen(b) + 1
    call malloc         ; rax es la cantidad de bytes para `a++b`
    mov r14, rax        ; preservo string 'out'

    mov rdi, rax        ; Puntero mutable a la string concatenada

    ; char* p = a;
    ; while (*p != 0) {
    ;     *out = *p
    ;     out++
    ;     p++
    ; }
    mov rsi, r12                        ; rsi = a. puntero para recorrer 'a'
    jmp .cond_a                         ; salta directo a la guarda
  .loop_a:
        mov dl, [rsi]                   ; Leo 1 char de a
        mov [rdi], dl                   ; Escribo 1 char 'out'
        inc rsi                         ; a++
        inc rdi                         ; out++
  .cond_a:
    cmp BYTE [rsi], 0   ; Chequea *a != \0
    jne .loop_a

    ; char* p = b;
    ; while (*p != 0) {
    ;     *out = *p
    ;     out++
    ;     p++
    ; }
    mov rsi, r13                        ; rsi = b. puntero para recorrer 'b'
    jmp .cond_b
  .loop_b:
        mov dl, [rsi]       ; leo 1 char de 'b'
        mov [rdi], dl       ; Escribo 1 char en 'out'
        inc rsi             ; b++
        inc rdi             ; out++
  .cond_b:
    cmp BYTE [rsi], 0   ; Chequea *b != \0
    jne .loop_b

    mov BYTE [rdi], 0   ; Escribe terminador nulo en 'out'


    ; En el manejo de memoria del programa, es esta funcion quien debe liberar
    ; 'a' y 'b'.

    ; si a == b, solo libera una vez.
    cmp r12, r13
    je .free_b

  .free_a:
    mov rdi, r12                        ; rdi = a (1er param)
    call free                           ; free(a)

  .free_b:
    mov rdi, r13                        ; rdi = b (1er param)
    call free                           ; free(b)

    ; return 'out'
    mov rax, r14

    add rsp, 8
    pop r14
    pop r13
    pop r12

    pop rbp
    ret

strDelete:
    push rbp
    mov rbp, rsp

    call free

    pop rbp
    ret

; void strPrint(char* a, FILE *pFile);
;               RDI      RSI
strPrint:
    push rbp
    mov rbp, rsp

    mov rdx, rdi                          ; 3er arg = a
    mov rdi, rsi                          ; 1er arg = pfile
    mov rsi, strPrint_formatter           ; 2do arg = "%s"

    ; Si la string es vacia, imprime NULL
    cmp BYTE [rdx], 0                     ; cmp a[0], NUL
    jne .print

      mov rdx, strPrint_null              ; a = "NULL"

  .print:
    call fprintf ; fprintf(pfile, "%s" a)

    pop rbp
    ret

; list_t* listNew();
; RAX
listNew:
    push rbp
    mov rbp, rsp

    mov rdi, LIST_SIZE ; rsi = # bytes para un list_t
    call malloc        ; Pide memoria para un list_t

    ; Inicializa ambos punteros en null
    mov QWORD [rax + LIST_OFF_FIRST], NULL
    mov QWORD [rax + LIST_OFF_LAST], NULL

    pop rbp
    ret

; listElem_t* auxNewListElem(void* data, listElem_t* prev, listElem_t* next) {
; //RAX                      RDI         RSI               RDX
;     listElem_t* new = (listElem_t*) malloc(24);
;     new->data = data;
;     new->next = next;
;     new->prev = prev;
;     return new;
; }
auxNewListElem:
    push rbp
    mov rbp, rsp

    push rdx                            ; Preservo 'next'
    push rsi                            ; Preservo 'prev'
    push rdi                            ; Preservo 'data'
    sub rsp, 8                          ; Balanceo stack

    mov rdi, LISTELEM_SIZE
    call malloc                         ; Pido espacio p/ listElem_t

    add rsp, 8

    pop rdx                             ; rdx = data
    mov [rax + LISTELEM_OFF_DATA], rdx  ; new->data = data

    pop rdx                             ; rdx = prev
    mov [rax + LISTELEM_OFF_PREV], rdx  ; new->prev = prev

    pop rdx                             ; rdx = prev
    mov [rax + LISTELEM_OFF_NEXT], rdx  ; new->next = next

    pop rbp
    ret

; void listAddFirst(list_t* l, void* data) {
; //                RDI        RSI
;     listElem_t* new = auxNewListElem(data, NULL, l->first);
;     if (l->first) {
;         l->first->prev = new;
;     } else {
;         l->last = new;
;     }
;     l->first = new;
; }
listAddFirst:
    push rbp
    mov rbp, rsp

    mov rdx, [rdi + LIST_OFF_FIRST]     ; 3er param = 'l->first'
    push rdi                            ; preservo l
    sub rsp, 8                          ; balanceo stack
    mov rdi, rsi                        ; 1er param = 'data'
    mov rsi, NULL                       ; 2do param = 'null'
    call auxNewListElem                 ; Creo nuevo elemento

    add rsp, 8
    pop rdx                             ; rdx = l

    cmp QWORD [rdx + LIST_OFF_FIRST], 0 ; Se fija si la lista es vacia
    jnz .else_branch
    mov [rdx + LIST_OFF_LAST], rax      ; l->last = new
    jmp .endif
  .else_branch:
                                        ; l->first->prev = new
    mov rcx, [rdx + LIST_OFF_FIRST]     ; rcx = l->first
    mov [rcx + LISTELEM_OFF_PREV], rax  ; l->first->prev = new
  .endif:

    mov [rdx + LIST_OFF_FIRST], rax     ; l->first = new

    pop rbp
    ret

; void listAddLast(list_t* l, void* data) {
; //               RDI        RSI
;     listElem_t* new = auxNewListElem(data, l->last, NULL);
;     if (l->first) {
;         l->last->next = new
;     } else {
;         l->first = new
;     }
;     l->last = new;
; }
listAddLast:
    push rbp
    mov rbp, rsp

    push rdi                                ; Preservo l
    sub rsp, 8                              ; balanceo stack

    mov rax, [rdi + LIST_OFF_LAST]          ; rax = l->last (temporal)
    mov rdi, rsi                            ; 1er param = data
    mov rsi, rax                            ; 2do param = l->last
    mov rdx, NULL                           ; 3er param = NULL
    call auxNewListElem                     ; auxNewListElem(data, l->last, NULL);

    add rsp, 8
    pop rdx                                 ; rdx = l

    cmp QWORD [rdx + LIST_OFF_FIRST], NULL  ; if (l->first == NULL)
    jne .last_elem_exists

    mov [rdx + LIST_OFF_FIRST], rax         ; l->first = new

    jmp .endif                              ; evita caer en guarda else
  .last_elem_exists:
                                            ; l->last->next = new
    mov rcx, [rdx + LIST_OFF_LAST]          ; >   rcx = l->last
    mov [rcx + LISTELEM_OFF_NEXT], rax      ; >   l->last->next = new
  .endif:

    mov [rdx + LIST_OFF_LAST], rax          ; l->last = new

    pop rbp
    ret

; void listAdd(list_t* l, void* data, funcCmp_t* fc)
;              RDI        RSI         RDX
listAdd:
    push rbp
    mov rbp, rsp

    push rbx                              ; guardo registros preservados
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8                            ; balanceo stack

    mov rbx, rdi                          ; rbx = l
    mov r12, rsi                          ; r12 = data
    mov r13, rdx                          ; r13 = fc

    mov r14, [rbx + LIST_OFF_FIRST]       ; e_next: r14 = l->first
    mov r15, NULL                         ; e_prev: r15 = NULL

    jmp .cmp
  .loop:

    mov r15, r14                          ; e_prev = e_next
    mov r14, [r14 + LISTELEM_OFF_NEXT]    ; e_next = e_next->next

  .cmp:
    cmp r14, NULL                         ; e_next == NULL (fin de la lista)
    je .add                               ; Si se termina ahi la lista lo pone ahi
    mov rdi, [r14 + LISTELEM_OFF_DATA]    ; 1er arg = 'e_next->data'
    mov rsi, r12                          ; 2do arg = data
    call r13                              ; cmp(data, e->data)
    cmp rax, 1                            ; data < e->data
    je .loop

  .add:

    mov rdi, r12                          ; 1st arg = data
    mov rsi, r15                          ; 2nd arg = e_prev
    mov rdx, r14                          ; 3rd arg = e_next
    call auxNewListElem                   ; auxNewListElem(data, e_prev, e_next)

    cmp r15, NULL                         ; si e_prev == null. Se puso al principio
    je .fix_l_first                       ; 
  .fix_e_prev:                            ; Arregla e_prev->next
    mov [r15+LISTELEM_OFF_NEXT], rax      ; e_prev->next = new
    jmp .endif1
  .fix_l_first:                           ; arregla l->first porque se puso al principio
    mov [rbx+LIST_OFF_FIRST], rax         ; l->first = new
  .endif1:

    cmp r14, NULL                         ; si e_next == null, se puso al final
    je .fix_l_last
  .fix_e_next:                            ; Se puso antes de 'e_next'. Arreglo 'e_next->prev'
    mov [r14 + LISTELEM_OFF_PREV], rax    ; e_next->prev = new
    jmp .endif2
  .fix_l_last:                            ; Se puso al final. arreglo l->last
    mov [rbx + LIST_OFF_LAST], rax        ; l->last = new
  .endif2:

    add rsp, 8                            ; borro basura del stack
    pop rbx                               ; Restauro registros preservadas
    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret

; void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd);
;                 RDI        RSI         RDX            RCX
listRemove:
    push rbp
    mov rbp, rsp

    push r12                            ; Pusheo variables que debo preservar
    push r13
    push r14
    push r15
    push rbx                            ; Guarda que el stack esta desbalanceado

                                        ; uso variables preservadas xq se hacen muchos calls
    mov r12, rdi                        ; r12 = l
    mov r13, rsi                        ; r13 = data
    mov r14, rdx                        ; r14 = fc
    mov r15, rcx                        ; r15 = fd

    mov rbx, [r12 + LIST_OFF_FIRST]     ; e = l->first

                                        ; while (e != NULL)
    jmp .cmp                            ; jmp a guarda del loop
  .loop:                                ; Cuerpo del loop
    mov rdx, [rbx + LISTELEM_OFF_NEXT]  ; e_next = e->next
    push rdx

                                        ; 'if (fc(e->data, data) == 0)':
    mov rdi, [rbx+LISTELEM_OFF_DATA]    ; 1er arg = e->data
    mov rsi, r13                        ; 2do arg = data
    call r14                            ; fc(e->data, data)
    cmp rax, 0                          ; fc(e->data, data) == 0
    jne .endif
  .then:                                ; Procede a borrar el elemento

  .fix_l_first:                         ; if (l->first == e)
    cmp [r12+LIST_OFF_FIRST], rbx       ; ZF = l->first == e
    jne .fix_l_last                     ; si no es el primero, no hay que arreglarlo
    mov rax, [rbx + LISTELEM_OFF_NEXT]  ; 'rax = e->next'
    mov [r12+LIST_OFF_FIRST], rax       ; l->first = (e->next)

  .fix_l_last:                          ; if (l->last == e)
    cmp [r12+LIST_OFF_LAST], rbx        ; ZF = 'l->last == e'
    jne .remove_e                       ; Si no es el ultimo, no toca l->last
    mov rax, [rbx + LISTELEM_OFF_PREV]  ; rax = e->prev
    mov [r12+LIST_OFF_LAST], rax        ; l->last = e->prev

  .remove_e:                            ; procede a borrar e
    mov rdi, rbx                        ; 1er arg = e
    mov rsi, r15                        ; 2do arg = fd
    call aux_list_elem_remove           ; aux_list_elem_remove(e, fd)

  .endif:                               ; fin del 'if (fc(e->data, data) == 0)'

    pop rdx                             ; rdx = e_next
    mov rbx, rdx                        ; e = e_next
  .cmp:                                 ; guarda del loop
    cmp rbx, NULL                       ; e == null?
    jne .loop                           ; while(e != null)

    pop rbx                             ; Restauro variables preservadas
    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret

listRemoveFirst:
    push rbp
    mov rbp, rsp

    ; if (l->first == NULL) return;
    cmp QWORD [rdi + LIST_OFF_FIRST], 0
    je .ret

    mov rax, [rdi+LIST_OFF_FIRST]       ; rax = l->first
    mov rdx, [rax+LISTELEM_OFF_NEXT]    ; rdx = (l->first)->next
    mov [rdi+LIST_OFF_FIRST], rdx       ; (l->first) = (l->first)->next

    cmp rdx, NULL                       ; si 'e->next == null' va a vaciar lista
    jne .remove                         ; Si no es null, no hay que tocar 'e->last'
    mov QWORD [rdi+LIST_OFF_LAST], NULL ; l = []

  .remove:
    mov rdi, rax                        ; 1st arg = e
    call aux_list_elem_remove           ; aux_list_elem_remove(e, fd)

  .ret:

    pop rbp
    ret

; void listRemoveLast(list_t* l, funcDelete_t* fd) {
;                     RDI         RSI
;   listElem_t* e = l->last
;   l->last = e->prev           // Corrijo 'l'
;   if (e->prev == NULL) {
;       l->first = NULL
;   }
;   aux_list_elem_remove(e, fd) // Borro 'e'
; }
listRemoveLast:
    push rbp
    mov rbp, rsp

    ; if (l->first == NULL) return;
    cmp QWORD [rdi + LIST_OFF_FIRST], 0
    je .ret

    mov rax, [rdi + LIST_OFF_LAST]         ; rax = e = l->last
    mov rdx, [rax + LISTELEM_OFF_PREV]     ; rdx = (l->last)->prev
    mov [rdi + LIST_OFF_LAST], rdx         ; l->last = (l->last)->prev

    cmp rdx, NULL                          ; si 'e->prev == NULL', estamos vaciando la lista
    jne .remove_elem                       ; si no estamos vaciando, no toca l->first
    mov QWORD [rdi + LIST_OFF_FIRST], NULL ; l->first = NULL

  .remove_elem:
    mov rdi, rax                           ; 1er arg = e
    call aux_list_elem_remove              ; aux_list_elem_remove(e, fd)

  .ret:

    pop rbp
    ret

; void aux_list_elem_remove(listElem_t* e, funcDelete_t* fd)
;                           RDI            RSI
; Si 'fd != 0', usa la funcion. No especifica que quieren que hagamos cuando
; 'fd == 0' no borro el dato asumiendo que si lo quiero borrar con 'free',
; puedo pasar 'free'
aux_list_elem_remove:
    push rbp
    mov rbp, rsp

    mov rax, [rdi + LISTELEM_OFF_PREV]  ; rax = e->prev
    mov rdx, [rdi + LISTELEM_OFF_NEXT]  ; rax = e->next

  .fix_prev:
    cmp rax, NULL                       ; null?(e->prev)
    je .fix_next                        ; Si es null saltea
    mov [rax + LISTELEM_OFF_NEXT], rdx  ; (e->prev)->next = (e->next)

  .fix_next:
    cmp rdx, NULL                       ; null?(e->next)
    je .delete_data                     ; Si es null saltea
    mov [rdx + LISTELEM_OFF_PREV], rax  ; (e->next)->prev = (e->prev)

  .delete_data:                         ; borra e->data

    cmp rsi, NULL                       ; null?(fd)
    je .delete_elem                     ; Solo borra e->data si 'fd != null'

    push rdi                            ; preservo 'e'
    sub rsp, 8                          ; Balancea stack

    mov rdi, [rdi + LISTELEM_OFF_DATA]  ; 1er arg = e->data
    call rsi                            ; fd(e->data)

    add rsp, 8                          ; Saca basura del stack
    pop rdi                             ; Restaura '1er arg = e'

  .delete_elem:
    call free                           ; 'free(e)'

    pop rbp
    ret

; void listDelete(list_t* l, funcDelete_t* fd)
;                 RDI        RSI
listDelete:
    push rbp
    mov rbp, rsp

    push r12
    push r13

    mov r12, [rdi + LIST_OFF_FIRST]  ; r12 = l->first
    mov r13, rsi                     ; r13 = fd

    ; Borro 'l' no la necesito mas
    call free                        ; free(l)

    ; Recorro la lista borrando elemento por elemento
    ; Invariante: ( r12 = e && r13 = fd)
    jmp .cmp
  .loop:                             ; borra proximo elemento



  .loop_libera_data:                      ; Borra 'e->data' de ser necesario

    cmp r13, NULL                         ; Se fija si hay una 'fd'
    je .loop_free_e                       ; Si 'fd == NULL' saltea este paso

    mov rdi, [r12 + LISTELEM_OFF_DATA]    ; 1er arg = dato
    call r13                              ; fd(dato)



  .loop_free_e:                           ; libera 'e'

    mov rdi, r12                          ; 1er arg = e
    mov r12, [r12 + LISTELEM_OFF_NEXT]    ; e = e->next. Avanza
    call free                             ; Libera el elemento

  .cmp:
    cmp r12, NULL                    ; while(e != NULL) 
    jne .loop                        ; Salta al cuerpo del loop

    pop r13
    pop r12

    pop rbp
    ret

; void listPrint(list_t* l, FILE *pFile, funcPrint_t* fp)
;                RDI        RSI          RDX
;    fprintf(pfile, "[")
;    e = l->first
;    while (e != null)
;         if ( fp != null ) {
;             fp( e->data, pFile )
;         } else {
;             fprintf("%p", e->data)
;         }
;
;         e = e->next
;
;         if (e) {
;             fprintf(pfile, ",");
;         }
;     }
;
;     fprintf(pfile, "]")
; }
listPrint:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, [rdi + LIST_OFF_FIRST]       ; r12 = e = l->first
    mov r13, rsi                          ; r13 = pFile
    mov r14, rdx                          ; r14 = fp

    ; fprint(pFile, "[");
    mov rdi, r13                          ; <- pFile
    mov rsi, listPrint_bracket_open       ; <- ptr a "["
    call fprintf                          ; fprint(pFile, "[");

    ; while (e)
    jmp .cmp
  .loop:
    
    ; if (fp != NULL)
    cmp r14, NULL                         ; fp == null
    je .print_ptr                         ; if (fp == null), imprimr address

    ; fp(e->data, pFile)
    mov rdi, [r12 + LISTELEM_OFF_DATA]    ; 1er arg = e->data
    mov rsi, r13                          ; 2do arg = pFile
    call r14                              ; fp(e->data, pFile)

    jmp .endprint

  .print_ptr: ; "else"

    ; fprintf(pFile, "%p", e->data)
    mov rdi, r13                          ; 1er arg = pFile
    mov rsi, listPrint_ptr                ; 2do arg = "%p"
    mov rdx, [r12 + LISTELEM_OFF_DATA]    ; 3er arg = e->data
    call fprintf                          ; fprintf(pFile, "%p", e->data)

  .endprint: ; "endif"

    mov r12, [r12 + LISTELEM_OFF_NEXT]    ; e = e->next

    ; if (e != null) : print(",")
    cmp r12, NULL                         ; e == null
    je .cmp                               ; if (e -= null), continue

    ; fprintf(pFile, ",")
    mov rdi, r13                          ; 1er arg = pfile
    mov rsi, listPrint_comma              ; 2do arg = ","
    call fprintf                          ; fprintf(pFile, ",")

  .cmp:
    cmp r12, NULL                         ; e == NULL
    jne .loop                             ; while ( e != NULL )

    ; fprint(pFile, "[");
    mov rdi, r13                          ; <- pFile
    mov rsi, listPrint_bracket_close      ; <- ptr a "["
    call fprintf                          ; fprint(pFile, "[");


    add rsp, 8
    pop r14
    pop r13
    pop r12

    pop rbp
    ret

n3treeNew:
    push rbp
    mov rbp, rsp

    mov rdi, N3TREE_SIZE  ; 1arg tam en bytes de un n3tree_t
    call malloc           ; pido mem para hacer un n3tree_t

    mov QWORD [rax + N3TREE_OFF_FIRST], NULL ; Inicializo puntero first

    pop rbp
    ret

; n3treeElem_t* aux_new_n3treeElem(void* data)
;                                  RDI
aux_new_n3treeElem:
    push rbp
    mov rbp, rsp

    push rdi                              ; preservo data
    sub rsp, 8                            ; balanceo stack

    call listNew                          ; rax = ptr a nueva lista vacia

    ; mov rsp, rax                        ; Sobreescribo basura stack con addr nueva list FIXME usa esto si funciona
    add rsp, 8                            ; saco basura stack
    push rax                              ; preservo nueva list

    mov rdi, N3TREEELEM_SIZE              ; Pido memoria para un n3treeElem_t
    call malloc

    mov QWORD [rax + N3TREEELEM_OFF_LEFT], NULL ; new->left es NULL
    mov QWORD [rax + N3TREEELEM_OFF_RIGHT], NULL ; new->right es NULL

    pop rdx                                ; rdx = addr lista vacia
    mov [rax + N3TREEELEM_OFF_CENTER], rdx ; new->center apunta a lista vacia

    pop rdx                                ; rdx = data
    mov [rax + N3TREEELEM_OFF_DATA], rdx   ; new->data = data

    ; Devuelve el address del nuevo n3treeElem_t que fue creado.

    pop rbp
    ret

; void n3treeAdd(n3tree_t* t, void* data, funcCmp_t* fc);
;                RDI          RSI         RDX
n3treeAdd:
    push rbp
    mov rbp, rsp

    push r12                                ; esta funcion hace muchos
    push r13                                ; llamados recursivos, por lo que
    push r14                                ; lo mejor es preservar en registros
    push r15                                ; preservados.

    ; FIXME si no se usa r15, no lo pushees

    mov r12, rdi                            ; r12 = t
    mov r13, rsi                            ; r13 = data
    mov r14, rdx                            ; r14 = fc

    cmp QWORD [r12 + N3TREE_OFF_FIRST], NULL ; Si el arbol es vacio
    je .write_empty

    mov r12, [r12 + N3TREE_OFF_FIRST]       ; r12 = raiz(t)

  .loop:

    ; fc(data, n->data)
    mov rdi, r13                            ; 1er arg = data
    mov rsi, [r12 + N3TREEELEM_OFF_DATA]    ; 2do arg = n->data
    call r14                                ; fc(data, n->data)

    cmp rax, 0                              ; si resultado es EQ
    je .write_eq                            ; salta a escribir el dato en 'n'

    cmp rax, 1                              ; si el resultado es LT
    je .caso_lt                             ; Salta si el resultado es 1 > 0

  .caso_gt:
    cmp QWORD [r12 + N3TREEELEM_OFF_RIGHT], NULL ; si no hay nodo donde avanzar
    je .write_gt                                 ; crea nodo a la derecha para el dato
    mov r12, [r12 + N3TREEELEM_OFF_RIGHT],       ; r12: 'n = n->right'
    jmp .loop

  .caso_lt: ; (data < n->data)
    cmp QWORD [r12 + N3TREEELEM_OFF_LEFT], NULL ; Si no hay nodo donde avanzar
    je .write_lt                                ; Crea un nodo a la izquierda para el dato
    mov r12, [r12 + N3TREEELEM_OFF_LEFT]        ; r12: 'n = n->left'
    jmp .loop

    ; Fin del loop que recorre arbol  ------

    ; Cuando se encuentra un nodo 'n' cuyo dato 'n->data == data', se escribe
    ; 'data' en la lista 'n->center'
    ; Asume 'r12 = n', 'r13 = data'
  .write_eq:
    ; Pongo el dato en la lista del nodo
    mov rdi, [r12 + N3TREEELEM_OFF_CENTER]  ; 1er arg = n->center
    mov rsi, r13                            ; 2do arg = data
    call listAddFirst                       ; listAddFirst(n->center, data)
    jmp .end

    ; Cuando se encuentra un nodo 'n' tal que 'data < n->data' pero
    ; 'n->left = NULL', se debe crear un nuevo nodo y apuntarlo desde n->left
    ; Asume 'r12 = n', 'r13 = data'
  .write_lt:
    ; Crea un nodo 'new' con 'data'
    mov rdi, r13                            ; 1er arg = data
    call aux_new_n3treeElem                 ; aux_new_n3treeElem(data)
    ; Lo apunta desde 'n'
    mov [r12 + N3TREEELEM_OFF_LEFT], rax    ; n->left = new
    jmp .end                                ; Termina algoritmo

    ; Cuando se encuentra un nodo 'n' tal que 'n->data < data' pero
    ; 'n->right = NULL', se debe crear un nuevo nodo y apuntarlo desde n->right
    ; Asume 'r12 = n', 'r13 = data'
  .write_gt:
    ; Crea un nodo 'new' con 'data'
    mov rdi, r13                            ; 1er arg = data
    call aux_new_n3treeElem                 ; aux_new_n3treeElem(data)
    ; Lo apunta desde 'n'
    mov [r12 + N3TREEELEM_OFF_RIGHT], rax   ; n->right = new
    jmp .end                                ; Termina algoritmo

    ; Cuando el arbol esta vacio, se debe crear un nodo 'new' y apuntarlo en
    ; 't->first'.
    ; Espera recibir 'r12 = t', 'r13 = data'
  .write_empty:
    ; Crea un nodo 'new' con 'data'
    mov rdi, r13                            ; 1er arg = data
    call aux_new_n3treeElem                 ; aux_new_n3treeElem(data)
    mov [r12 + N3TREE_OFF_FIRST], rax       ; n->first = new
    jmp .end

  .end:

    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret

; void _n3tree_removeeq_aux(n3treeElem_t* e, funcDelete_t* fd)
;                           RDI              RSI
_n3tree_removeeq_aux:
    push rbp
    mov rbp, rsp

    cmp rdi, NULL
    je .end

    push r12
    push r13

    mov r12, rdi  ; r12 = e
    mov r13, rsi  ; r13 = fd

    ; Hago llamado a listDelete para borrar la lista.
    mov rdi, [r12 + N3TREEELEM_OFF_CENTER] ; 1er arg = e->center
    mov rsi, r13                           ; 2do arg = fd
    call listDelete                        ; listDelete(e->center, fd);

    ; Pongo una lista vacia para que cumpla el invariante de la struct
    call listNew                           ; rax = listNew()
    mov [r12 + N3TREEELEM_OFF_CENTER], rax ; e->center == []

    ; Llamo recursivamente a esta funcion para el hijo izquierdo
    mov rdi, [r12 + N3TREEELEM_OFF_LEFT]   ; 1er arg = e->left
    mov rsi, r13                           ; 2do arg = fd
    call _n3tree_removeeq_aux              ; _n3tree_removeeq_aux(e->left, fd)

    ; Llamo recursivamente a esta funcion para el hijo derecho
    mov rdi, [r12 + N3TREEELEM_OFF_RIGHT]  ; 1er arg = e->right
    mov rsi, r13                           ; 2do arg = fd
    call _n3tree_removeeq_aux              ; _n3tree_removeeq_aux(e->right, fd)

    pop r13
    pop r12

  .end:
    pop rbp
    ret

; void n3treeRemoveEq(n3tree_t* t, funcDelete_t* fd)
;                     RDI          RSI
n3treeRemoveEq:
    push rbp
    mov rbp, rsp

    mov rdi, [rdi + N3TREE_OFF_FIRST] ; 1er arg = t->first
    call _n3tree_removeeq_aux         ; _n3tree_removeeq_aux(t->first, fd)

    pop rbp
    ret

; void _n3tree_elem_delete(n3treeElem_t* e, funcDelete_t* fd)
;                          RDI              RSI
_n3tree_elem_delete:
    push rbp
    mov rbp, rsp

    ; if (e == NULL) return;
    cmp rdi, NULL
    je .end

    push r12
    push r13
    mov r12, rdi                          ; r12 = e
    mov r13, rsi                          ; r13 = fd

    ; Borra el dato (de ser fd != NULL)
    cmp r13, NULL                         ; fd == NULL
    je .endif                             ; if (FD != NULL)
    mov rdi, [r12 + N3TREEELEM_OFF_DATA]  ; |    1er arg = e->data
    call r13                              ; |    fd(e->data)
  .endif:

    ; Limpia la lista center
    mov rdi, [r12 + N3TREEELEM_OFF_CENTER] ; 1er arg = e->center
    mov rsi, r13                           ; 2do arg = fd
    call listDelete                        ; listDelete(e->center, fd)

    ; se llama recursivamente para limpiar e->left
    mov rdi, [r12 + N3TREEELEM_OFF_LEFT]   ; 1er arg = e->left
    mov rsi, r13                           ; 2nd arg = fd
    call _n3tree_elem_delete               ; _n3tree_elem_delete(e->left, fd)

    ; se llama recursivamente para limpiar e->right
    mov rdi, [r12 + N3TREEELEM_OFF_RIGHT]  ; 1er arg = e->right
    mov rsi, r13                           ; 2nd arg = fd
    call _n3tree_elem_delete               ; _n3tree_elem_delete(e->right, fd)

    ; una vez liberado todx lo que se apuntaba Borra la estructura e
    mov rdi, r12                            ; 1er arg = e
    call free                               ; free(e)

    pop r13
    pop r12

  .end:
    pop rbp
    ret

; void n3treeDelete(n3tree_t* t, funcDelete_t* fd)
;                   RDI          RSI
n3treeDelete:
    push rbp
    mov rbp, rsp

    push r12
    sub rsp, 8

    mov r12, rdi                          ; Preservo 't' que voy a liberar despues

    ; Borra recursivamente todos los nodos
    mov rdi, [r12 + N3TREE_OFF_FIRST]     ; 1er arg = t->first
    call _n3tree_elem_delete              ; _n3tree_elem_delete(t->first, fd)

    ; Borra el n3tree_t
    mov rdi, r12                          ; 1er arg = t
    call free                             ; free(t)

    add rsp, 8
    pop r12

    pop rbp
    ret

; nTable_t* nTableNew(uint32_t size)
; RAX                 EDI
nTableNew:
    push rbp
    mov rbp, rsp

    push r12
    push r13

    mov r12, rdi                      ; r12d = size

    ; t = malloc(SIZE_NTABLE)
    mov edi, SIZE_NTABLE              ; sizeof(nTable_t)
    call malloc                       ; malloc(sizeof(nTable_t))
    mov r13, rax                      ; r13 = t

    ; t->size = size
    mov [r13 + NTABLE_OFF_SIZE], r12d ; t->size = size

    ; Pido memoria para el array de listas
    mov rdi, r12                      ; edi = size
    shl rdi, 8                        ; 1er arg = edi = size * 8 (tamano de un ptr)
    call malloc                       ; rax = malloc( size * SIZE_PTR )
    mov [r13 + NTABLE_OFF_LISTARRAY], rax ; t->listArray = malloc( size * SIZE_PTR )

    ; 'while(size > 0)'
    jmp .cmp                          ; Salta a la guarda
  .loop:

        call listNew                          ; rax = listNew()

        ; decremento el contador size, que voy a usar para offsetear la posicion
        ; del puntero que tengo que escribir con la lista vacia.
        dec r12d                              ; size --
        mov rdx, [r13 + NTABLE_OFF_LISTARRAY] ; rdx = t->listArray
        mov [rdx + r12 * 8], rax             ; t->listArray[size] = listNew()

  .cmp:
    cmp r12d, 0                       ; size > 0
    jnz .loop                         ; while (size > 0)

    mov rax, r13

    pop r13
    pop r12

    pop rbp
    ret

; void nTableAdd(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc)
;               RDI           RSI           RDX`          RCX
nTableAdd:
    push rbp
    mov rbp, rsp

    ; Acota slot con %t->size
    mov r8, rdx                           ; preservo data
    xor rdx, rdx                          ; limpio parte alta dividendo
    mov eax, esi                          ; dividendo = slot
    div DWORD [rdi + NTABLE_OFF_SIZE]     ; edx = slot % t->size
    mov rsi, rdx                          ; acoto slot
    mov rdx, r8                           ; restauro data

    mov rdi, [rdi + NTABLE_OFF_LISTARRAY] ; rdi = t->listArray       (1er arg)
    mov rdi, [rdi + rsi * SIZE_PTR]       ; rdi = t->listArray[slot] (1er arg)

    mov rsi, rdx                          ; rsi = data (2do arg)
    mov rdx, rcx                          ; rcx = fc   (3er arg)

    call listAdd                          ; listAdd(t->listArray[slot], data, fc)

    pop rbp
    ret

; void nTableRemoveSlot(nTable_t* t, uint32_t slot, void* data, funcCmp_t* fc, funcDelete_t* fd)
;                       RDI           RSI           RDX           RCX           r8
nTableRemoveSlot:
    push rbp
    mov rbp, rsp

    mov rdi, [rdi + NTABLE_OFF_LISTARRAY] ; rdi = t->listArray       (1er arg)
    mov rdi, [rdi + rsi * SIZE_PTR]       ; rdi = t->listArray[slot] (1er arg)

    mov rsi, rdx                          ; data                     (2do arg)
    mov rdx, rcx                          ; fc                       (3er arg)
    mov rcx, r8                           ; fd                       (4to arg)

    call listRemove                       ; listRemove(t, data, fc, fd)

    pop rbp
    ret

; void nTableDeleteSlot(nTable_t* t, uint32_t slot, funcDelete_t* fd)
;                       RDI           RSI             RDX
nTableDeleteSlot:
    push rbp
    mov rbp, rsp

    push r12
    push r13

    mov rcx, rdx                          ; preservo rcx = fd

    ; Acota slot con t->size
    ; rsi = slot % t->size
    xor edx, edx                          ; anulo parte alta del dividendo
    mov eax, esi                          ; parte baja dividendo = slot
    div DWORD [rdi + NTABLE_OFF_SIZE]     ; divido por su tamano (edx:eax / t->size)
    mov esi, edx                          ; slot = slot % t->size (edx)

    mov r12, rdi                          ; r12 = t
    mov r13, rsi                          ; r13 = slot

    ; Borro la lista vieja
    mov rdi, [r12 + NTABLE_OFF_LISTARRAY] ; rdi = t->listArray       (1er arg)
    mov rdi, [rdi + r13 * SIZE_PTR]       ; rdi = t->listArray[slot] (1er arg)
    mov rsi, rcx                          ; rsi = fd                 (2do arg)
    call listDelete                       ; listDelete(t->listArray[slot], fd)

    ; Creo una lista vacia
    call listNew                          ; rax = listNew()

    mov r12, [r12 + NTABLE_OFF_LISTARRAY] ; r12 = t->listArray
    mov [r12 + r13 * SIZE_PTR], rax       ; t->listArray[slot] = listNew()

    pop r13
    pop r12

    pop rbp
    ret

; void nTableDelete(nTable_t* t, funcDelete_t* fd)
;                       RDI           RSI
nTableDelete:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, rdi                          ; r12 = t
    mov r13d, [r12 + NTABLE_OFF_SIZE]     ; r13d = t->size ( "n" )
    mov r14, rsi                          ; r14 = fd

    ; while ( 0 < n )
    jmp .cmp
  .loop:

        dec r13d                              ; n--

        mov rdi, [r12 + NTABLE_OFF_LISTARRAY] ; rdi = t->listArray       (1er arg)
        mov rdi, [rdi + r13  * SIZE_PTR]       ; rdi = t->listArray[n]    (1er arg)

        mov rsi, r14                          ; rsi = fd                 (2do arg)

        call listDelete                       ; listDelete(l->listArray[n], fd)

  .cmp:
    cmp r13d, 0
    jg .loop                              ; while ( slot > 0 )

    mov rdi, [r12 + NTABLE_OFF_LISTARRAY] ; rdi = t->listArray      (1er arg)
    call free                             ; free(t->listArray)

    mov rdi, r12                          ; rdi = t                 (1er arg)
    call free                             ; free(t)

    add rsp, 8
    pop r14
    pop r13
    pop r12

    pop rbp
    ret
