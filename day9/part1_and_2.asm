global create_first_two_marbles
global insert_marble_after
global destroy_marbles
global remove_marble_at

extern malloc
extern free

struc marble_node
   .prev: resq 1
   .next: resq 1
   .value: resq 1
endstruc
MARBLE_NODE_SIZE equ 24

create_first_two_marbles:
    push        rbx
    mov         rdi, MARBLE_NODE_SIZE
    call        malloc
    mov         rbx, rax

    mov         rdi, MARBLE_NODE_SIZE
    call        malloc

    mov         qword [rbx + marble_node.prev], rax
    mov         qword [rbx + marble_node.next], rax
    mov         qword [rbx + marble_node.value], 0

    mov         qword [rax + marble_node.prev], rbx
    mov         qword [rax + marble_node.next], rbx
    mov         qword [rax + marble_node.value], 1

    pop         rbx
    ret

insert_marble_after: ; ptr to head, int64 new_value
    push        r12
    push        r13
    sub         rsp, 8 ; stack alignment

    mov         r12, rdi
    mov         r13, rsi

    mov         rdi, MARBLE_NODE_SIZE
    call        malloc

    mov         qword [rax + marble_node.prev], r12
    mov         rcx, [r12 + marble_node.next]
    mov         qword [rax + marble_node.next], rcx
    mov         qword [rax + marble_node.value], r13

    mov         qword [rcx + marble_node.prev], rax
    mov         qword [r12 + marble_node.next], rax

    add         rsp, 8
    pop         r13
    pop         r12
    ret

destroy_marbles: ; head of marbles
    push        rbx

    mov         rax, qword [rdi + marble_node.prev]
    mov         qword [rax + marble_node.next], 0
    mov         rbx, qword [rdi + marble_node.next]

    .prepare_to_remove_current_head:
    mov         rbx, rax

    .remove_current_head:
    call        free
    mov         rax, qword [rbx + marble_node.next]
    mov         rdi, rbx
    cmp         rax, 0
    jne         .prepare_to_remove_current_head

.exit_point:
    mov         rdi, rbx
    call        free
    pop         rbx
    ret

remove_marble_at: ; ptr to head of marbles
    push        rbp
    push        rbx
    push        r12

    mov         rbx, rdi

    mov         rdi, qword [rdi + marble_node.prev]
    mov         rdx, qword [rdi + marble_node.next]
    mov         rbp, qword [rdi + marble_node.value]

    mov         qword [rdx + marble_node.prev], rdi
    mov         qword [rdi + marble_node.next], rdx

    mov         r12, qword [rdi + marble_node.next]
    call        free

    mov         qword [rbx], r12
    mov         rax, rbp

    pop         r12
    pop         rbx
    pop         rbp
    ret
