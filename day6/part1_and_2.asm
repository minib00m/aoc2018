global calculate_point_areas
global calculate_border_points

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

        mov     rdi, rdx
        mov     esi, 4
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

calculate_border_points: ; ptr to distance cell array, array width, array height, all points
        push    rbp
        push    r12
        push    rbx
        sub     rsp, 8

        mov     rbx, rdi
        movsx   rbp, esi
        movsx   r12, edx

        mov     rdi, rsi
        imul    rdi, r12
        mov     rsi, 1
        call    calloc ; result in rax, stays in rax until end of this function

        ; (r8; r9) -> range to iterate vertically
        ; (r10; r11) -> range to iterate horizontally
        mov     r8, 0
        lea     r9, [r12 - 1]
        lea     r11, [rbp - 1]
.prepare_loop_vertically:
        cmp     r8, r9
        jg      .return_value
        mov     r10, 0

.prepare_loop_horizontally:
        cmp     r10, r11
        jle     .loop_horizontally
        inc     r8
        jmp     .prepare_loop_vertically

.loop_horizontally:
        ; check if point is a border one
        cmp     r8, 0
        je      .process_border_point
        cmp     r10, 0
        je      .process_border_point
        cmp     r8, r9
        je      .process_border_point
        cmp     r10, r11
        je      .process_border_point
        inc     r10
        jmp     .prepare_loop_horizontally

.process_border_point:
        mov     rdx, rbp ; width
        imul    rdx, r8 ; width * current_y
        add     rdx, r10 ; width * current_y + current_x
        imul    rdx, DISTANCE_CELL_SIZE
        inc     r10
        cmp     dword [rbx + distance_cell.is_alone + rdx], 0
        je      .prepare_loop_horizontally
        movsx   rcx, dword [rbx + distance_cell.alone_id + rdx]
        mov     byte [rax + rcx], 1
        jmp     .prepare_loop_horizontally

.return_value:
        add     rsp, 8
        pop     rbx
        pop     r12
        pop     rbp
        ret
