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

section .rodata

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

    push rsi            ; Preservo 'b'
    push rdi            ; Preservo 'a'

    call strLen         ; eax = strlen(a); rdi y rsi = indef

    push rax            ; Preservo `strLen(a)`
    sub rsp, 8          ; Balanceo stack

    mov rdi, [rsp + 24] ; Leo b sin sacar del stack
    call strLen         ; eax = strlen(b)

                        ; Pido memoria para `out = a++b`
    add rsp, 8
    pop rdi             ; edi = strlen(a)
    add edi, eax        ; edi = strLen(a) + strLen(b)
    inc edi             ; edi = strLen(a) + strLen(b) + 1
    call malloc         ; rax -> cantidad de bytes para `a++b`

    mov rdi, rax        ; Puntero mutable a la string concatenada

                        ; Copio 'a'
    pop rsi             ; puntero a 'a'
    jmp .cond_a
  .loop_a:
    mov dl, [rsi]       ; Leo 1 char de a
    mov [rdi], dl       ; Escribo 1 char en la string de salida 'out'
    inc rsi             ; a++
    inc rdi             ; out++
  .cond_a:
    cmp BYTE [rsi], 0   ; Chequea *a != \0
    jne .loop_a

    pop rsi             ; puntero a 'b'
    jmp .cond_b
  .loop_b:
    mov dl, [rsi]       ; leo 1 char de 'b'
    mov [rdi], dl       ; Escribo 1 char en la string de salida 'out'
    inc rsi             ; b++
    inc rdi             ; out++
  .cond_b:
    cmp BYTE [rsi], 0   ; Chequea *b != \0
    jne .loop_b

    mov BYTE [rdi], 0   ; Escribe terminador nulo en 'out'

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

    ; Swap `rdi` <-> `rsi`
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rax

    call fprintf ; fprintf(pfile, a)

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

    mov rax, [rdi+LIST_OFF_FIRST]       ; rax = l->first
    mov rdx, [rax+LISTELEM_OFF_NEXT]    ; rdx = (l->first)->next
    mov [rdi+LIST_OFF_FIRST], rdx       ; (l->first) = (l->first)->next

    cmp rdx, NULL                       ; si 'e->next == null' va a vaciar lista
    jne .remove                         ; Si no es null, no hay que tocar 'e->last'
    mov QWORD [rdi+LIST_OFF_LAST], NULL ; l = []

  .remove:
    mov rdi, rax                        ; 1st arg = e
    call aux_list_elem_remove           ; aux_list_elem_remove(e, fd)

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

    mov rax, [rdi + LIST_OFF_LAST]         ; rax = e = l->last
    mov rdx, [rax + LISTELEM_OFF_PREV]     ; rdx = (l->last)->prev
    mov [rdi + LIST_OFF_LAST], rdx         ; l->last = (l->last)->prev

    cmp rdx, NULL                          ; si 'e->prev == NULL', estamos vaciando la lista
    jne .remove_elem                       ; si no estamos vaciando, no toca l->first
    mov QWORD [rdi + LIST_OFF_FIRST], NULL ; l->first = NULL

  .remove_elem:
    mov rdi, rax                           ; 1er arg = e
    call aux_list_elem_remove              ; aux_list_elem_remove(e, fd)

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

listPrint:
    ret

n3treeNew:
    push rbp
    mov rbp, rsp

    mov rdi, N3TREE_SIZE  ; 1arg tam en bytes de un n3tree_t
    call malloc           ; pido mem para hacer un n3tree_t

    mov QWORD [rax + N3TREE_OFF_FIRST], NULL ; Inicializo puntero first

    pop rbp
    ret

n3treeAdd:
    ret

n3treeRemoveEq:
    ret

n3treeDelete:
    ret

nTableNew:
    ret

nTableAdd:
    ret

nTableRemoveSlot:
    ret

nTableDeleteSlot:
    ret

nTableDelete:
    ret
