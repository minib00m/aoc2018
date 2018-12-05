extern scanf
%include 'utils/double_buffer.asm'

EOF equ -1
NEWLINE_CHAR equ 10

section .data
input_char_format: db "%c", 0

section .text
initialize_string_buffer: ; ptr to string buffer
    mov     qword [BUFPTR(rdi)], 0
    mov     qword [BUFSIZE(rdi)], 8
    mov     qword [BUFENTRYSIZEOF(rdi)], 1
    double_buffer   rdi
    ret

read_string: ; ptr to string buffer
    push    rbp
    push    r12 ; keep current position in buffer
    push    r13 ; keep pointer to input
    mov     rbp, rsp
    sub     rsp, 8 ; for input byte

    xor     r12, r12
    mov     r13, rdi
.read_next_char:
    mov     rdi, input_char_format
    lea     rsi, [rbp - 1]
    mov     al, 0
    call    scanf

    cmp     eax, EOF
    je      .exit_point
    cmp     eax, NEWLINE_CHAR
    je      .exit_point

    cmp     r12, [BUFSIZE(r13)]
    jl      .put_element_to_buffer

    double_buffer r13

.put_element_to_buffer:
    movzx   r8, byte [rbp - 1]
    mov     rcx, [BUFPTR(r13)]
    mov     rax, [BUFENTRYSIZEOF(r13)]
    mov     r8, [BUFENTRYSIZEOF(r13)]
    imul    r8, r12
    lea     r9, [rcx + r8]
    inc     qword [BUFENTRYSIZEOF(r13)]
    mov     byte [r9], r8

    inc     r12
    jmp     .read_next_char

.exit_point:
    add     rsp, 8
    pop     r13
    pop     r12
    pop     rbp
    ret
