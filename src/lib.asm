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

listAdd:
    ret

listRemove:
    ret

listRemoveFirst:
    ret

listRemoveLast:
    ret

listDelete:
    ret

listPrint:
    ret

n3treeNew:
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
