global main

extern scanf
extern printf

ALPHABET_COUNT equ 26
EOF equ -1
section .data
node_visited: times ALPHABET_COUNT db 0
node_in_degree: times ALPHABET_COUNT dd 0
node_matrix: times ALPHABET_COUNT * ALPHABET_COUNT db 0
topologically_sorted_nodes: times ALPHABET_COUNT db 0
topological_sort_index: dq 0
is_node_present: times ALPHABET_COUNT db 0

INPUT_FORMAT: db "Step %c must be finished before step %c can begin.", 10, 0
SHOW_FORMAT: db "Best node to process: %c", 10, 0
DEBUG_FORMAT: db "Elo witam", 10, 0

PRINT_BYTE: db "%c", 0

section .text

print_byte_array_as_A_Z_range: ; address to byte array, size of byte array
    push        rbp
    push        rbx
    sub         rsp, 8 ; stack alignment

    mov         rbx, rdi
    lea         rbp, [rbx + rsi] ; first non valid address
    cmp         rbx, rbp
    je          .exit_point

.print_byte:
    mov         rdi, PRINT_BYTE
    movsx       rsi, byte [rbx]
    add         rsi, 'A'
    mov         eax, 0
    call        printf
    inc         rbx
    cmp         rbx, rbp
    jne         .print_byte

.exit_point:
    add         rsp, 8
    pop         rbx
    pop         rbp
    ret

decrease_in_degree_for_neighbours: ; node
    mov         byte [node_visited + rdi], 1
    ; start of the row in node_matrix
    imul        rax, rdi, ALPHABET_COUNT
    lea         rdi, [node_matrix + rax]
    xor         rsi, rsi
.check_if_edge_exists:
    cmp         byte [rdi + rsi], 0
    je          .prepare_next_node_to_check
    dec         byte [node_in_degree + rsi]

.prepare_next_node_to_check:
    inc         rsi
    cmp         rsi, ALPHABET_COUNT
    jne          .check_if_edge_exists
    ret


best_node_to_process: ; returns -1 if there is no node to process
    xor         rax, rax
.check_if_good_node:
    cmp         byte [node_visited + rax], 0
    jne         .prepare_next_node_to_check

    cmp         byte [node_in_degree + rax], 0
    jne         .prepare_next_node_to_check

    cmp         byte [is_node_present + rax], 1
    jne         .prepare_next_node_to_check
    ret

.prepare_next_node_to_check:
    inc         rax
    cmp         rax, ALPHABET_COUNT
    jl          .check_if_good_node
    mov         rax, -1
    ret

main:
    push        rbp
    mov         rbp, rsp
    sub         rsp, 16 ; byte for keeping current node, byte for from node, byte for to node, stack alignment

.read_next_line:
    mov         rdi, INPUT_FORMAT
    lea         rsi, [rbp - 1]
    lea         rdx, [rbp - 2]
    mov         eax, 0
    call        scanf
    cmp         eax, EOF
    je          .do_topological_sort

    ; to node
    movsx       rdx, byte [rbp - 2]
    sub         rdx, 'A'
    inc         byte [node_in_degree + rdx]
    mov         byte [is_node_present + rdx], 1

    ; from node
    movsx       rax, byte [rbp - 1]
    sub         rax, 'A'
    mov         byte [is_node_present + rax], 1

    ; mark edge as present
    imul        rax, ALPHABET_COUNT
    add         rax, rdx
    mov         byte [node_matrix + rax], 1

    jmp         .read_next_line

.do_topological_sort:
    ; find first non visited node with zero in degree
    call        best_node_to_process
    cmp         rax, EOF
    je          .print_result_part1
    mov         rdi, rax
    mov         qword [rbp - 16], rax
    call        decrease_in_degree_for_neighbours
    mov         rax, qword [rbp - 16]
    ; save current node
    mov         rcx, [topological_sort_index]
    mov         byte [topologically_sorted_nodes + rcx], al
    inc         qword [topological_sort_index]
    jmp         .do_topological_sort

.print_result_part1:
    mov         rdi, topologically_sorted_nodes
    mov         rsi, [topological_sort_index]
    call        print_byte_array_as_A_Z_range

    add         rsp, 16
    pop         rbp
    ret
