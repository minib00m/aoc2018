global claims_area_overlap

extern calloc
extern free

struc claim
    .no: resq 1
    .top_x: resq 1
    .top_y: resq 1
    .width: resq 1
    .height: resq 1
endstruc

struc overlap_result
    .overlapped_claims_area: resq 1
    .loner_no: resq 1
endstruc

CLAIM_SIZE equ 40

section .text

get_max_area: ; ptr to first claim array element, size of array
    xor     r8, r8 ; current index
    xor     rax, rax ; max height
    xor     rcx, rcx ; max width

.check_next_claim:
    cmp     r8, rsi
    je      .return_max_area
    imul    rdx, r8, CLAIM_SIZE
    lea     r9, [rdi + rdx]
    mov     r10, [r9 + claim.top_x]
    add     r10, [r9 + claim.width]
    mov     r11, [r9 + claim.top_y]
    add     r11, [r9 + claim.height]
    cmp     rcx, r10
    cmovl   rcx, r10
    cmp     rax, r11
    cmovl   rax, r11
    inc     r8
    jmp     .check_next_claim

.return_max_area:
    ; first parameter returned in rax
    ; second parameter returned in rdx
    ret

claims_area_overlap: ; ptr to first claim array element, size of array, ptr to result struct
    push    rbp
    push    r12 ; keep first argument
    push    r13 ; keep second argument
    push    r14 ; ptr to memory for marking overlaps
    push    r15 ; overlapped area claims, to be returned in rax
    mov     rbp, rsp
    sub     rsp, 24 ; buffer width, ptr to result struct, stack alignment

    mov     r12, rdi
    mov     r13, rsi
    mov     [rbp - 16], rdx
    call    get_max_area
    mov     rdi, rax
    imul    rdi, rdx
    mov     [rbp - 8], rdx
    mov     rsi, 8 ; we only need one byte, but screw it
    call    calloc
    mov     r14, rax

    xor     rcx, rcx ; current index
    xor     r15, r15 ; area overlaps

.check_next_claim:
    cmp     rcx, r13
    je      .find_loner_id
    imul    rax, rcx, CLAIM_SIZE
    lea     rax, [r12 + rax]
    mov     r8, [rax + claim.top_x]
    mov     r9, r8
    add     r9, [rax + claim.width]

    ; horizontally loop from r8 to r9
    ; vertically loop from r10 to r11
.loop_horizontally:
    cmp     r8, r9
    jl      .loop_vertically_prepare
    inc     rcx
    jmp     .check_next_claim

.loop_vertically_prepare:
    mov     r10, [rax + claim.top_y]
    mov     r11, r10
    add     r11, [rax + claim.height]

.loop_vertically:
    cmp     r10, r11
    jl      .continue_looping_vertically
    inc     r8
    jmp     .loop_horizontally

.continue_looping_vertically:
    mov     rdi, r10
    imul    rdi, [rbp - 8]
    add     rdi, r8
    lea     rsi, [r14 + rdi * 8]
    inc     r10
    inc     qword [rsi]
    cmp     qword [rsi], 2
    je      .subtract_from_overlaps
    jmp     .loop_vertically

.subtract_from_overlaps:
    inc     r15 ; we want to increase overlaps count
    jmp     .loop_vertically

;;;;;; second part  ;;;;;;
.find_loner_id:
    xor     rcx, rcx ; current index

.check_next_claim_for_being_loner:
    cmp     rcx, r13
    je      .return_overlap_result
    xor     rdx, rdx
    imul    rax, rcx, CLAIM_SIZE
    lea     rax, [r12 + rax]
    mov     r8, [rax + claim.top_x]
    mov     r9, r8
    add     r9, [rax + claim.width]

    ; horizontally loop from r8 to r9
    ; vertically loop from r10 to r11
.loop_horizontally2:
    cmp     r8, r9
    jl      .loop_vertically_prepare2
    inc     rcx
    cmp     rdx, 0
    je      .found_a_loner
    jmp     .check_next_claim_for_being_loner
.found_a_loner:
    mov     rdx, [rax + claim.no]
    jmp     .return_overlap_result

.loop_vertically_prepare2:
    mov     r10, [rax + claim.top_y]
    mov     r11, r10
    add     r11, [rax + claim.height]

.loop_vertically2:
    cmp     r10, r11
    jl      .continue_looping_vertically2
    inc     r8
    jmp     .loop_horizontally2

.continue_looping_vertically2:
    mov     rdi, r10
    imul    rdi, [rbp - 8]
    add     rdi, r8
    lea     rsi, [r14 + rdi * 8]
    inc     r10
    cmp     qword [rsi], 1 ; is it great candidate for a loner?
    je      .loop_vertically2
    inc     rcx ; its not a good candidate
    mov     rdx, 1
    jmp     .check_next_claim_for_being_loner

.return_overlap_result:
    ; rdx already contains result
    ; but its hard to return a struct, especially when different compilers generate different code
    mov     rcx, [rbp - 16]
    mov     [rcx + overlap_result.overlapped_claims_area], r15
    mov     [rcx + overlap_result.loner_no], rdx
    mov     rdi, r14
    call    free
    add     rsp, 24
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    ret
