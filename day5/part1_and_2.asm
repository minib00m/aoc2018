global main
%include 'utils/double_buffer.asm'

extern strlen
extern scanf
extern printf
extern malloc
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

input_format: db "%ms", 0
dbg_format: db "%s", 10, 0
solution_output_format: db "part%d: %ld", 10, 0

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

polymer_length_after_reaction: ; ptr to polymer string, size of polymer
    push    rbp
    push    r12 ; current position in polymer string
    push    r13 ; save ptr to polymer string
    push    r14 ; save size of polymer
    mov     rbp, rsp
    sub     rsp, 8 ; stack alignment

    cmp     rsi, 0
    je      .return_results
    xor     r12, r12
    mov     r13, rdi
    mov     r14, rsi
    mov     qword [char_buffer_position], 0 ; zero our buffer

    movzx   edi, byte [r13 + r12]
    call    add_char_to_buffer
    inc     r12

.process_next_char:
    cmp     r12, r14
    je      .return_results
    movzx   edi, byte [r13 + r12]
    cmp     edi, NEWLINE_CHAR
    je      .return_results

    call    isupper
    cmp     eax, 0 ; is lower
    je      .handle_lower_case
.handle_upper_case:
    movzx   edi, byte [r13 + r12]
    add     edi, 32
    call    remove_top_element_if_matches
    cmp     rax, 0 ; element not removed
    je      .put_element_to_buffer
    inc     r12
    jmp     .process_next_char

.handle_lower_case:
    movzx   edi, byte [r13 + r12]
    sub     edi, 32
    call    remove_top_element_if_matches
    cmp     rax, 0 ; element not removed
    je      .put_element_to_buffer
    inc     r12
    jmp     .process_next_char

.put_element_to_buffer:
    movzx   edi, byte [r13 + r12]
    call    add_char_to_buffer
    inc     r12
    jmp     .process_next_char

.return_results:
    mov     rax, [char_buffer_position]

    add     rsp, 8
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    ret


remove_letter_from_polymer: ; ptr to polymer, size of polymer, lowercase letter to exclude
    push    rbp
    push    r12 ; return value
    push    r13 ; first argument
    push    r14 ; second argument
    push    r15 ; third argument
    mov     rbp, rsp
    sub     rsp, 16 ; temporary buffer, stack alignment

    mov     r13, rdi
    mov     r14, rsi
    movzx   r15, dl

    lea     rdi, [r14 + 1]
    call    malloc
    mov     r12, rax

    xor     rcx, rcx ; current polymer index
    xor     rdx, rdx ; current buffer index
.rewrite_next_letter:
    cmp     rcx, r14
    je      .exit_point
    movzx   eax, byte [r13 + rcx]
    movzx   r8d, al
    add     r8d, 32 ; r8 holds uppercase letter now
    cmp     al, r15b
    je      .skip_letter
    cmp     r8b, r15b
    je      .skip_letter

    mov     [r12 + rdx], eax
    inc     rcx
    inc     rdx
    jmp     .rewrite_next_letter

.skip_letter:
    inc     rcx
    jmp     .rewrite_next_letter

.exit_point:
    mov     byte [r12 + rdx], 0 ; null terminate our polymer
    mov     rax, r12
    add     rsp, 16
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    ret

main:
    push    rbp
    push    r12
    push    r13
    push    r14
    mov     rbp, rsp
    sub     rsp, 24 ; ptr to input buffer, size of input buffer, stack alignment

    ; initialize char buffer
    double_buffer char_buffer

    mov     rdi, input_format
    lea     rsi, [rbp - 16]
    mov     rax, 0
    call    scanf

    mov     rdi, [rbp - 16]
    call    strlen
    mov     [rbp - 8], rax

    mov     rdi, [rbp - 16]
    mov     rsi, [rbp - 8]
    call    polymer_length_after_reaction

    mov     rdi, solution_output_format
    mov     rsi, 1
    mov     rdx, rax
    mov     rax, 0
    call    printf

    mov     r12, 'a' ; current character to remove
    mov     r13, [rbp - 8] ; minimum value
.check_next_letter:
    cmp     r12, 'z'
    jg      .print_part2_solution

    mov     rdi, [rbp - 16]
    mov     rsi, [rbp - 8]
    mov     rdx, r12
    call    remove_letter_from_polymer
    mov     r14, rax ; buffer to free
    mov     rdi, rax
    call    strlen
    mov     rdi, r14
    mov     rsi, rax
    call    polymer_length_after_reaction
    cmp     r13, rax
    cmovg   r13, rax
    mov     rdi, r14
    call    free
    inc     r12
    jmp     .check_next_letter

.print_part2_solution:
    mov     rdi, solution_output_format
    mov     rsi, 2
    mov     rdx, r13
    mov     rax, 0
    call    printf

    mov     rdi, [BUFPTR(char_buffer)]
    call    free
    mov     rdi, [rbp - 16]
    call    free
    mov     rax, 0
    add     rsp, 24
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    ret
