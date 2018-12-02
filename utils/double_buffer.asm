extern realloc

double_buffer: ; ptr to buffer, ptr to size to double
    mov     r8, qword [rsi]
    add     r8, r8
    mov     qword [rsi], r8
    imul    rsi, r8, 8 ; each element has 8 bytes
    jmp     realloc

