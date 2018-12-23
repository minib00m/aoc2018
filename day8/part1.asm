global main

extern scanf
extern printf

section .data
INT64_INPUT: db "%ld", 0
INT64_OUTPUT: db "%ld", 10, 0

section .text
calculate_licence_sum:
    push        rbp
    push        r12 ; sum of childs entries
    push        r13 ; current child
    mov         rbp, rsp
    sub         rsp, 16 ; number of child nodes, number of metadata entries

    xor         r12, r12
    xor         r13, r13

    mov         rdi, INT64_INPUT
    lea         rsi, [rbp - 16]
    mov         eax, 0
    call        scanf

    mov         rdi, INT64_INPUT
    lea         rsi, [rbp - 8]
    mov         eax, 0
    call        scanf

    .read_next_child_entry:
    cmp         r13, qword [rbp - 16]
    je          .read_self_meta_entries
    call        calculate_licence_sum
    add         r12, rax
    inc         r13
    jmp         .read_next_child_entry

    .read_self_meta_entries:
    xor         r13, r13
    .read_next_meta_entry:
    cmp         r13, qword [rbp - 8]
    je          .return_result
    mov         rdi, INT64_INPUT
    lea         rsi, [rbp - 16] ; hijacking this memory
    mov         eax, 0
    call        scanf
    add         r12, qword [rbp - 16]
    inc         r13
    jmp         .read_next_meta_entry

    .return_result:
    mov         rax, r12
    add         rsp, 16
    pop         r13
    pop         r12
    pop         rbp
    ret



main:
    sub         rsp, 8
    call        calculate_licence_sum
    mov         rdi, INT64_OUTPUT
    mov         rsi, rax
    mov         eax, 0
    call        printf

    add         rsp, 8
    ret
