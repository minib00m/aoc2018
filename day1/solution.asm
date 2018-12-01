global main

extern scanf
extern printf

section .data
integer_format: db "%d", 0
integer_format2: db "%d", 10, 0

section .text

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16 ; int and stack alignment

    mov     rdi, integer_format
    lea     rsi, [rbp - 8]
    mov     al, 0
    call    scanf

    mov     rsi, qword [rbp - 8]
    mov     rdi, integer_format2
    mov     al, 0
    call    printf

    add     rsp, 16
    pop     rbp
    mov     rax, 0
    ret
