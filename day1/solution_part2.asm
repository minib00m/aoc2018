global main

extern scanf
extern printf
extern malloc
extern free
extern realloc

EOF equ -1

section .data
input_buffer: dq 0
input_buffer_size: dq 8
input_buffer_position: dq 0

buf: dq 0
buf_size: dq 8
buf_position: dq 0

input_int64_format: db "%ld", 0
output_int64_format: db "%ld", 10, 0

section .text

is_element_in_frequencies_buffer: ; element to search in list
    mov     rcx, 0 ; index

.check_next_element:
    cmp     rcx, [buf_position] ; check if not out of bounds
    jge     .no_such_element
    mov     rdx, [buf]
    mov     r8, [rdx + rcx * 8] ; getting element
    inc     rcx
    cmp     r8, rdi
    jne     .check_next_element
    mov     rax, 1
    ret

.no_such_element:
    xor     rax, rax
    ret

double_buffer: ; ptr to buffer, ptr to size to double
    mov     r8, qword [rsi]
    add     r8, r8
    mov     qword [rsi], r8
    imul    rsi, r8, 8 ; each element has 8 bytes
    jmp     realloc

process_input_buffer:
    push    rbp
    mov     rbp, rsp
    push    r12 ; current input_buffer index
    push    r13 ; current sum of frequencies

    ; add 0 to initial frequencies buffer
    mov     rax, [buf]
    mov     qword [rax], 0
    inc     qword [buf_position]

    xor     r12, r12
    xor     r13, r13
.process_element_in_input_buffer:
    xor     rax, rax
    cmp     [input_buffer_position], r12
    cmovle  r12, rax ; zero our index if it's too high

    mov     rax, [input_buffer]
    add     r13, [rax + r12 * 8] ; add next element to our sum
    inc     r12
    mov     rdi, r13
    call    is_element_in_frequencies_buffer
    cmp     rax, 0
    jne     .doubled_frequency_found

    ; sum frequency not found, add it to frequencies buffer
    mov     rax, [buf_size]
    cmp     [buf_position], rax
    jl      .put_element_to_frequencies_buffer

    ; realloc frequencies buffer
    mov     rdi, [buf]
    mov     rsi, buf_size
    call    double_buffer
    mov     [buf], rax

.put_element_to_frequencies_buffer:
    mov     rax, [buf_position]
    mov     rcx, [buf]
    lea     r8, [rcx + rax * 8]
    inc     qword [buf_position]
    mov     [r8], r13
    jmp     .process_element_in_input_buffer

.doubled_frequency_found:
    mov     rax, r13

    pop     r13
    pop     r12
    pop     rbp
    ret

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16 ; int64 for input, stack alignment

    ; initialize frequencies buffer
    mov     rdi, qword [buf]
    mov     rsi, buf_size
    call    double_buffer
    mov     qword [buf], rax

    ; initialize input_buffer
    mov     rdi, qword [input_buffer]
    mov     rsi, input_buffer_size
    call    double_buffer
    mov     qword [input_buffer], rax

.read_more:
    mov     rdi, input_int64_format
    lea     rsi, [rbp - 8]
    mov     al, 0
    call    scanf
    cmp     eax, EOF
    je      .process_input_buffer

    mov     r8, [input_buffer_size]
    cmp     [input_buffer_position], r8
    jl     .put_element_into_buffer

    ; relocating buffer
    mov     rdi, [input_buffer]
    mov     rsi, input_buffer_size
    call    double_buffer
    mov     qword [input_buffer], rax

.put_element_into_buffer:
    mov     r8, [rbp - 8] ; element to add
    mov     rax, [input_buffer_position]
    mov     rcx, [input_buffer] ; base address of buffer
    lea     r9, [rcx + rax * 8]
    inc     qword [input_buffer_position]
    mov     [r9], r8
    jmp     .read_more

.process_input_buffer:
     call   process_input_buffer
     mov    rdi, output_int64_format
     mov    rsi, rax
     mov    al, 0
     call   printf

.free_buffer:
    mov     rdi, [buf]
    call    free
    mov     rdi, [input_buffer]
    call    free

.exit_point:
    add     rsp, 16
    pop     rbp
    mov     rax, 0
    ret

