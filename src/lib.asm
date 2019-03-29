BITS 64

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

listNew:
    ret

listAddFirst:
    ret

listAddLast:
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
