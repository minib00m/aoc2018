global main
%include 'utils/double_buffer.asm'
%include 'utils/buffer.asm'

extern scanf
extern printf
extern free
extern isupper

EOF equ -1
NEWLINE_CHAR equ 10

section .data
char_buffer istruc buffer
    at buffer.ptr, dq 0
    at buffer.size, dq 8
    at buffer.entry_sizeof, dq 1
iend
char_buffer_position: dq 0

input_char_format: db "%c", 0
output_int64_format: db "%ld", 10, 0

section .text

add_char_to_buffer: ; char to add in edi
    push    rbx
    mov     ebx, edi
    mov     r8, [char_buffer_position]
    cmp     r8, [BUFSIZE(char_buffer)]
    jl      .put_char_to_buffer
    double_buffer char_buffer
.put_char_to_buffer:
    mov     rcx, [BUFPTR(char_buffer)]
    mov     r8, [char_buffer_position]
    mov     byte [rcx + r8], bl
    inc     qword [char_buffer_position]
    pop     rbx
    ret

remove_top_element_if_matches: ; char to check if matches in edi
    xor     rax, rax
    mov     r8, [char_buffer_position]
    dec     r8
    mov     rcx, [BUFPTR(char_buffer)]
    movzx   r9d, byte [rcx + r8]
    cmp     r9d, edi
    jne     .exit_point
    mov     rax, 1 ; return that element got removed
    dec     qword [char_buffer_position]
.exit_point:
    ret


main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16 ; byte for input, stack alignment

    ; initialize char buffer
    double_buffer char_buffer

    ; read first char and put it into the buffer
    ; next chars gonna be compared with top element in buffer and maybe added
    mov     rdi, input_char_format
    lea     rsi, [rbp - 1]
    mov     al, 0
    call    scanf
    cmp     eax, EOF
    je      .print_results
    movzx   edi, byte [rbp - 1]
    call    add_char_to_buffer
.read_next_char:
    mov     rdi, input_char_format
    lea     rsi, [rbp - 1]
    mov     al, 0
    call    scanf
    cmp     eax, EOF
    je      .print_results
    cmp     byte [rbp - 1], NEWLINE_CHAR
    je      .print_results

    movzx   edi, byte [rbp - 1]
    call    isupper
    cmp     eax, 0 ; is lower
    je      .handle_lower_case
.handle_upper_case:
    movzx   edi, byte [rbp - 1]
    add     edi, 32
    call    remove_top_element_if_matches
    cmp     rax, 0 ; element not removed
    je      .put_element_to_buffer
    jmp     .read_next_char

.handle_lower_case:
    movzx   edi, byte [rbp - 1]
    sub     edi, 32
    call    remove_top_element_if_matches
    cmp     rax, 0 ; element not removed
    je      .put_element_to_buffer
    jmp     .read_next_char

.put_element_to_buffer:
    movzx   edi, byte [rbp - 1]
    call    add_char_to_buffer
    jmp     .read_next_char

.print_results:
    mov     rdi, [BUFPTR(char_buffer)]
    call    free
    mov     rdi, output_int64_format
    mov     rsi, [char_buffer_position]
    mov     al, 0
    call    printf

    add     rsp, 16
    pop     rbp
    mov     rax, 0
    ret
