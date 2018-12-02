global main

extern scanf
extern printf

EOF equ -1
NEWLINE_CHAR equ 10
ALPHABET_COUNT equ 26
SMALL_A_ASCII equ 97

section .data
input_char_format: db "%c", 0
output_int64_format: db "%ld", 10, 0
letters_count: times ALPHABET_COUNT db 0

section .text

main:
    push    rbp
    push    r12 ; count of strings with any letter repeated twice
    push    r13 ; count of strings with any letter repeated thrice
    mov     rbp, rsp
    sub     rsp, 16 ; byte for input, stack alignment

    xor     r12, r12
    xor     r13, r13
.read_char_from_string:
    mov     rdi, input_char_format
    lea     rsi, [rbp - 1]
    mov     al, 0
    call    scanf

    cmp     eax, EOF
    je      .print_result

    movzx   eax, byte [rbp - 1]
    cmp     eax, NEWLINE_CHAR
    je      .process_read_string

    lea     r8, [letters_count + eax - SMALL_A_ASCII]
    inc     byte [r8]
    jne     .read_char_from_string

.process_read_string:
    mov     rcx, letters_count
    lea     rdx, [letters_count + ALPHABET_COUNT]

    xor     r8, r8 ; for marking if any letter repeated 2 times
    xor     r9, r9 ; for marking if any letter repeated 3 times
.check_next_letter:
    ; if out of bounds element, add r8 to r12 and r9 to r13
    cmp     rcx, rdx
    je      .summarize_word

    mov     al, [rcx] ; letter to check
    mov     byte [rcx], 0 ; zero letter count

    mov     r10, 1

    cmp     al, 2
    cmove   r8, r10

    cmp     al, 3
    cmove   r9, r10

    inc     rcx

    jmp .check_next_letter

.summarize_word:
    add     r12, r8
    add     r13, r9
    jmp     .read_char_from_string

.print_result:
    mov     rdi, output_int64_format
    mov     rsi, r12
    imul    rsi, r13
    xor     rax, rax
    call    printf

    add     rsp, 16
    pop     r13
    pop     r12
    pop     rbp
    mov     rax, 0
    ret
