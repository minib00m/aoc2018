global main

extern scanf
extern printf

ALPHABET_COUNT equ 26
MAX_WORKERS_COUNT equ 5
EOF equ -1
NO_SLOT_AVAILABLE equ -2
WORK_IN_PROGRESS equ -3

section .data
node_visited: times ALPHABET_COUNT db 0
node_in_degree: times ALPHABET_COUNT dd 0
node_matrix: times ALPHABET_COUNT * ALPHABET_COUNT db 0
topologically_sorted_nodes: times ALPHABET_COUNT db 0
topological_sort_index: dq 0
is_node_present: times ALPHABET_COUNT db 0
node_worker_rem_time: times MAX_WORKERS_COUNT db -1 ; no node
workers_node: times MAX_WORKERS_COUNT db 0
active_workers: dq 0
time_elapsed: dq 0

INPUT_FORMAT: db "Step %c must be finished before step %c can begin.", 10, 0
PRINT_INT64: db "%ld", 10, 0

section .text

best_node_to_process: ; returns -1 if there is no node to process
                      ; returns -2 if there is no slot available
                      ; otherwise returns node to process
    xor         rcx, rcx
    .check_if_good_node:
    cmp         byte [node_visited + rcx], 0
    jne         .prepare_next_node_to_check

    cmp         byte [node_in_degree + rcx], 0
    jne         .prepare_next_node_to_check

    cmp         byte [is_node_present + rcx], 1
    jne         .prepare_next_node_to_check

    cmp         qword [active_workers], MAX_WORKERS_COUNT
    je          .no_slot_available

    mov         rax, rcx
    jmp         .exit_point

    .prepare_next_node_to_check:
    inc         rcx
    cmp         rcx, ALPHABET_COUNT
    jl          .check_if_good_node

    cmp         qword [active_workers], 0
    jne         .work_in_progress

    .no_more_nodes:
    mov         rax, EOF
    jmp         .exit_point

    .no_slot_available:
    mov         rax, NO_SLOT_AVAILABLE
    jmp         .exit_point

    .work_in_progress:
    mov         rax, WORK_IN_PROGRESS
    jmp         .exit_point

    .exit_point:
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


set_node_to_free_worker: ; node
                         ; assumption: free node is present
    mov         byte [node_visited + rdi], 1
    mov         rcx, 0

    .search_for_free_worker:
    cmp         byte [node_worker_rem_time + rcx], -1
    je          .found_free_worker
    inc         rcx
    jmp         .search_for_free_worker

    .found_free_worker:
    mov         byte [workers_node + rcx], dil
    mov         byte [node_worker_rem_time + rcx], dil
    add         byte [node_worker_rem_time + rcx], 61
    inc         qword [active_workers]
    ret

make_time_tick: ; forward time by 1
                ; if any worker has completed its job - free them
    push        r12
    sub         rsp, 8 ; stack alignment
    xor         r12, r12

    .check_worker:
    cmp         byte [node_worker_rem_time + r12], 1 ; last tick!
    je          .free_done_worker

    cmp         byte [node_worker_rem_time + r12], -1
    je          .prepare_next_worker
    dec         byte [node_worker_rem_time + r12]

    .prepare_next_worker:
    inc         r12
    cmp         r12, MAX_WORKERS_COUNT
    je          .exit_point
    jmp         .check_worker

    .free_done_worker:
    mov         byte [node_worker_rem_time + r12], -1
    dec         qword [active_workers]
    movsx       rdi, byte [workers_node + r12]
    call        decrease_in_degree_for_neighbours
    jmp         .prepare_next_worker

    .exit_point:
    inc         qword [time_elapsed]
    add         rsp, 8
    pop         r12
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
    je          .do_parallel_topological_sort

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

    .do_parallel_topological_sort:
    call        best_node_to_process

    cmp         rax, EOF
    je          .print_result

    cmp         rax, NO_SLOT_AVAILABLE
    je          .forward_time

    cmp         rax, WORK_IN_PROGRESS
    je          .forward_time

    mov         rdi, rax
    call        set_node_to_free_worker
    jmp         .do_parallel_topological_sort
    .forward_time:
    call        make_time_tick
    jmp         .do_parallel_topological_sort

    .print_result:
    mov         rdi, PRINT_INT64
    mov         rsi, [time_elapsed]
    mov         eax, 0
    call        printf

    add         rsp, 16
    pop         rbp
    ret
