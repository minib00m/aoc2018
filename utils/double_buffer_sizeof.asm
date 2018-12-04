extern realloc

%macro double_buffer_sizeof 3 ; ptr to buffer, ptr to size to double, sizeof each element
    mov     rdi, %1
    mov     rsi, %2
    mov     r8, qword [rsi]
    add     r8, r8
    mov     qword [rsi], r8
    imul    rsi, r8, %3
    call    realloc
    mov     %1, rax
%endmacro
