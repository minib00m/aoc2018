global main

extern scanf
extern printf
extern malloc
extern free
extern realloc

EOF equ -1

section .data
buf: dq 0
buf_size: dq 64
buf_position: dq 0
input_integer: dq 0
input_int64_format: db "%ld", 0
output_int64_format: db "%ld", 10, 0

section .text

is_element_in_buffer: ; element to search in list
    mov     rcx, 0 ; index

.check_next_element:
    cmp     rcx, [buf_position] ; check if not out of bounds
    jge     .no_such_element
    mov     rdx, [buf + rcx * 8] ; getting element
    inc     rcx
    cmp     rdx, rdi
    jne     .check_next_element
    mov     rax, 1
    ret

.no_such_element:
    xor     rax, rax
    ret

double_buffer: ; ptr to buffer, ptr to size to double
    ret
    mov     r8, qword [rsi]
    add     r8, r8
    mov     qword [rsi], r8
    mov     rsi, r8
    jmp     realloc

main:
    push    rbp
    mov     rsp, rbp
    sub     rsp, 8
    ;sub     rsp, 16 ; int64 for input, stack alignment

    mov     rdi, buf
    mov     rsi, buf_size
    call    double_buffer ; first call to realloc equals to malloc

.read_more:
    mov     rdi, input_int64_format
    lea     rsi, [rbp - 8]
    mov     al, 0
    call    scanf

    cmp     eax, EOF
    je      .free_buffer ; no result found, TODO: implement going through list again

    mov     rdi, qword [rbp - 8]
    call    is_element_in_buffer

.free_buffer:
    lea     rdi, [rbp - 16]
    call    free


