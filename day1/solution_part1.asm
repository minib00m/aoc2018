global main

extern scanf
extern printf

EOF equ -1

section .data
input_int64_format: db "%ld", 0
output_int64_format: db "%ld", 10, 0

section .text

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; int64 for input, int64 for result, stack alignment
    mov     qword [rbp - 16], 0

.read_more:
    mov     rdi, input_int64_format
    lea     rsi, [rbp - 8]
    mov     al, 0
    call    scanf

    cmp     eax, EOF
    je      .print_result

    mov     r8, qword [rbp - 8]
    add     qword [rbp - 16], r8
    jmp     .read_more

.print_result:
    mov     rsi, qword [rbp - 16]
    mov     rdi, output_int64_format
    mov     al, 0
    call    printf

    add     rsp, 32
    pop     rbp
    mov     rax, 0
    ret
