extern realloc
%include 'utils/buffer.asm'

%macro double_buffer 1 ; ptr to buffer
    mov     rdi, [BUFPTR(%1)]
    mov     rsi, BUFSIZE(%1)
    mov     r8, qword [rsi]
    add     r8, r8
    mov     qword [rsi], r8
    mov     rsi, [BUFENTRYSIZEOF(%1)]
    imul    rsi, r8
    call    realloc
    mov     [BUFPTR(%1)], rax
%endmacro
