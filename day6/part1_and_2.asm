global calculate_point_areas

extern calloc

struc distance_cell
    .min_distance: resd 1
    .is_alone: resd 1
    .alone_id: resd 1
    .total_distance: resd 1
endstruc
DISTANCE_CELL_SIZE equ 16

section .text

calculate_point_areas: ; ptr to distance cell array, total amount of cells, all points
        push    rbp
        push    rbx
        sub     rsp, 8 ; stack alignment
        mov     rbx, rdi
        mov     rbp, rsi
        mov     esi, 4
        mov     rdi, rdx
        call    calloc ; result in rax, stays in rax until end of this function
        mov     rdx, rbx
        sal     rbp, 4 ; multiply by distance_cell struct size
        lea     rsi, [rbx + rbp] ; first non valid pointer
        jmp     .process_cell
.prepare_next_cell:
        add     rdx, DISTANCE_CELL_SIZE
        cmp     rdx, rsi
        je      .return_value
.process_cell:
        cmp     dword [rdx + distance_cell.is_alone], 0
        je      .prepare_next_cell
        movsx   rcx, dword [rdx + distance_cell.alone_id]
        add     dword [rax + rcx * 4], 1
        jmp     .prepare_next_cell
.return_value:
        add     rsp, 8
        pop     rbx
        pop     rbp
        ret
