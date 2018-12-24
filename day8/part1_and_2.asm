global main

extern scanf
extern printf
extern calloc
extern free

section .data
INT64_INPUT: db "%ld", 0
PART_OUTPUT: db "Part: %d, answer: %ld", 10, 0

section .text
calculate_licence_sum:
    push        rbp
    push        r12 ; sum of childs entries
    push        r13 ; current child
    push        r14 ; ptr to buffer
    push        r15 ; sum of childs, according to metadata
    mov         rbp, rsp
    sub         rsp, 32 ; number of metadata entries, number of child nodes, metadata entry

    xor         r12, r12
    xor         r13, r13
    xor         r15, r15

    mov         rdi, INT64_INPUT
    lea         rsi, [rbp - 16]
    mov         eax, 0
    call        scanf

    mov         rdi, INT64_INPUT
    lea         rsi, [rbp - 8]
    mov         eax, 0
    call        scanf

    mov         rdi, [rbp - 16]
    inc         rdi ; 1 based indexing
    mov         rsi, 8
    call        calloc
    mov         r14, rax

    .read_next_child_entry:
    cmp         r13, qword [rbp - 16]
    je          .read_self_meta_entries
    call        calculate_licence_sum
    add         r12, rax
    inc         r13
    mov         [r14 + r13 * 8], rcx
    jmp         .read_next_child_entry

    .read_self_meta_entries:
    xor         r13, r13
    .read_next_meta_entry:
    cmp         r13, qword [rbp - 8]
    je          .return_result
    mov         rdi, INT64_INPUT
    lea         rsi, [rbp - 24]
    mov         eax, 0
    call        scanf
    add         r12, qword [rbp - 24]
    inc         r13

    cmp         qword [rbp - 16], 0 ; if its zero, sum all meta-entries, otherwise sum according to metadata
    je          .read_next_meta_entry
    mov         rax, [rbp - 24]
    cmp         rax, 0
    je          .read_next_meta_entry
    cmp         rax, [rbp - 16]
    jg          .read_next_meta_entry
    add         r15, [r14 + rax * 8]
    jmp         .read_next_meta_entry

    .return_result:
    cmp         qword [rbp - 16], 0
    cmove       r15, r12
    mov         rdi, r14
    call        free
    mov         rax, r12
    mov         rcx, r15
    add         rsp, 32
    pop         r15
    pop         r14
    pop         r13
    pop         r12
    pop         rbp
    ret



main:
    push        rbp
    mov         rbp, rsp
    sub         rsp, 16

    call        calculate_licence_sum
    mov         qword [rbp - 16], rcx
    mov         rdi, PART_OUTPUT
    mov         rsi, 1
    mov         rdx, rax
    mov         eax, 0
    call        printf

    mov         rdi, PART_OUTPUT
    mov         rsi, 2
    mov         rdx, qword [rbp - 16]
    mov         eax, 0
    call        printf

    add         rsp, 16
    pop         rbp
    ret
