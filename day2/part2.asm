global print_most_similiar_strings

extern printf

section .data
char_format: db "%c", 0

section .text

diffing_number_of_letters: ; ptr to string, ptr to string
    xor     r8, r8 ; compare index
    xor     r9, r9 ; number of diffing indexes
.check_next_letter:
    movzx   edx, byte [rdi + r8]
    cmp     dl, 0
    je      .finish_function
    movzx   eax, byte [rsi + r8]
    inc     r8
    lea     r10, [r9 + 1]
    cmp     al, dl
    cmovne  r9, r10
    jmp     .check_next_letter

.finish_function:
    mov     rax, r9
    ret

print_most_similiar_strings: ; ptr to strings array, size of array
    push    r12 ; keep first argument
    push    r13 ; keep second argument
    push    r14 ; index of first string to compare
    push    r15 ; index of second string to compare
    mov     r12, rdi
    mov     r13, rsi
    xor     r14, r14 ; first loop

.check_outer_pair:
    cmp     r14, r13
    je      .finish_function
    lea     r15, [r14 + 1]
.check_inner_pairs:
    cmp     r15, r13
    jl      .continue_inner_loop
    inc     r14
    jmp     .check_outer_pair

.continue_inner_loop:
    mov     rdi, [r12 + r14 * 8]
    mov     rsi, [r12 + r15 * 8]
    call    diffing_number_of_letters
    cmp     rax, 1
    je      .print_result
    inc     r15
    jmp     .check_inner_pairs

.print_result:
    xor     r13, r13
.print_next_letter:
    mov     r10, [r12 + r14 * 8] ; first string
    mov     r11, [r12 + r15 * 8] ; second string
    movzx   eax, byte [r10 + r13]
    movzx   ecx, byte [r11 + r13]
    cmp     al, 0
    je      .finish_function
    cmp     al, cl
    jne     .increment_letter_index
    mov     rdi, char_format
    mov     rsi, rax
    mov     al, 0
    call    printf
.increment_letter_index:
    inc     r13
    jmp     .print_next_letter

.finish_function:
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    ret
