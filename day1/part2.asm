global main
%include 'utils/double_buffer_sizeof.asm'
%include 'utils/buffer.asm'

extern scanf
extern printf
extern malloc
extern free
extern realloc

EOF equ -1

section .data
input_buffer istruc buffer
    at buffer.ptr, dq 0
    at buffer.size, dq 8
iend
input_buffer_position: dq 0

frequency_buffer istruc buffer
    at buffer.ptr, dq 0
    at buffer.size, dq 8
iend
frequency_buffer_position: dq 0

input_int64_format: db "%ld", 0
output_int64_format: db "%ld", 10, 0

section .text

is_element_in_frequencies_buffer: ; element to search in list
    mov     rcx, 0 ; index

.check_next_element:
    cmp     rcx, [frequency_buffer_position] ; check if not out of bounds
    jge     .no_such_element
    mov     rdx, [BUFPTR(frequency_buffer)]
    mov     r8, [rdx + rcx * 8] ; getting element
    inc     rcx
    cmp     r8, rdi
    jne     .check_next_element
    mov     rax, 1
    ret

.no_such_element:
    xor     rax, rax
    ret

process_input_buffer:
    push    rbp
    mov     rbp, rsp
    push    r12 ; current input_buffer index
    push    r13 ; current sum of frequencies

    ; add 0 to initial frequencies buffer
    mov     rax, [BUFPTR(frequency_buffer)]
    mov     qword [rax], 0
    inc     qword [frequency_buffer_position]

    xor     r12, r12
    xor     r13, r13
.process_element_in_input_buffer:
    xor     rax, rax
    cmp     [input_buffer_position], r12
    cmovle  r12, rax ; zero our index if it's too high

    mov     rax, [BUFPTR(input_buffer)]
    add     r13, [rax + r12 * 8] ; add next element to our sum
    inc     r12
    mov     rdi, r13
    call    is_element_in_frequencies_buffer
    cmp     rax, 0
    jne     .doubled_frequency_found

    ; sum frequency not found, add it to frequencies buffer
    mov     rax, [BUFSIZE(frequency_buffer)]
    cmp     [frequency_buffer_position], rax
    jl      .put_element_to_frequencies_buffer

    ; realloc frequencies buffer
    double_buffer_sizeof [BUFPTR(frequency_buffer)], BUFSIZE(frequency_buffer), 8

.put_element_to_frequencies_buffer:
    mov     rax, [frequency_buffer_position]
    mov     rcx, [BUFPTR(frequency_buffer)]
    lea     r8, [rcx + rax * 8]
    inc     qword [frequency_buffer_position]
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
    double_buffer_sizeof [BUFPTR(frequency_buffer)], BUFSIZE(frequency_buffer), 8

    ; initialize input_buffer
    double_buffer_sizeof [BUFPTR(input_buffer)], BUFSIZE(input_buffer), 8

.read_more:
    mov     rdi, input_int64_format
    lea     rsi, [rbp - 8]
    mov     al, 0
    call    scanf
    cmp     eax, EOF
    je      .process_input_buffer

    mov     r8, [BUFSIZE(input_buffer)]
    cmp     [input_buffer_position], r8
    jl     .put_element_into_buffer

    ; relocating buffer
    double_buffer_sizeof [BUFPTR(input_buffer)], BUFSIZE(input_buffer), 8

.put_element_into_buffer:
    mov     r8, [rbp - 8] ; element to add
    mov     rax, [input_buffer_position]
    mov     rcx, [BUFPTR(input_buffer)] ; base address of buffer
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
    mov     rdi, [BUFPTR(frequency_buffer)]
    call    free
    mov     rdi, [BUFPTR(input_buffer)]
    call    free

.exit_point:
    add     rsp, 16
    pop     rbp
    mov     rax, 0
    ret

