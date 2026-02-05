;
;   MIT License
;
; Copyright (c) 2026 Viacheslav Komenda
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
; ==============================================================================
; MATH64 LIBRARY FOR TURBO PASCAL (16-BIT)
; CPU: 8086
; Calling Convention: Pascal FAR CALL (VAR params = Pointers)
; Data Type: Int64 (8 bytes)
; ==============================================================================
;
bits 16
cpu 8086

%ifdef TURBO
section CODE class=code
%else
section .text
%endif

; ==============================================================================
; EXPORTED SYMBOLS (UPPERCASE for Turbo Pascal linker)
; ==============================================================================
;
global S64ADD, U64ADD
global S64SUB, U64SUB
global S64NEG
global S64MUL, U64MUL
global S64DIV, U64DIV, S64MOD, U64MOD
global S64SHL, U64SHL
global S64SHR, U64SHR
global S64CMP, U64CMP
global S64TOA, U64TOA

; ==============================================================================
; ARITHMETIC OPERATIONS
; ==============================================================================

; ------------------------------------------------------------------------------
; S64ADD / U64ADD
; ------------------------------------------------------------------------------
S64ADD:
U64ADD:
    push bp
    mov bp, sp
    push ds
    push si
    push di
    push es

    ; Load A into Registers (DX:CX:BX:AX)
    lds si, [bp+10]     ; Pointer A
    mov ax, [si]
    mov bx, [si+2]
    mov cx, [si+4]
    mov dx, [si+6]

    ; Add B (Load pointer to ES:DI to preserve DS/A-regs)
    les di, [bp+6]      ; Pointer B
    add ax, [es:di]
    adc bx, [es:di+2]
    adc cx, [es:di+4]
    adc dx, [es:di+6]

    ; Store to Res
    les di, [bp+14]     ; Pointer Res
    mov [es:di], ax
    mov [es:di+2], bx
    mov [es:di+4], cx
    mov [es:di+6], dx

    pop es
    pop di
    pop si
    pop ds
    pop bp
    retf 12             ; Clean 3 ptrs * 4 bytes

; ------------------------------------------------------------------------------
; S64SUB / U64SUB
; ------------------------------------------------------------------------------
S64SUB:
U64SUB:
    push bp
    mov bp, sp
    push ds
    push si
    push di
    push es

    lds si, [bp+10]
    mov ax, [si]
    mov bx, [si+2]
    mov cx, [si+4]
    mov dx, [si+6]

    les di, [bp+6]
    sub ax, [es:di]
    sbb bx, [es:di+2]
    sbb cx, [es:di+4]
    sbb dx, [es:di+6]

    les di, [bp+14]
    mov [es:di], ax
    mov [es:di+2], bx
    mov [es:di+4], cx
    mov [es:di+6], dx

    pop es
    pop di
    pop si
    pop ds
    pop bp
    retf 12

; ------------------------------------------------------------------------------
; S64NEG
; ------------------------------------------------------------------------------
S64NEG:
    push bp
    mov bp, sp
    push ds
    push si
    push di
    push es

    lds si, [bp+6]      ; A
    mov ax, [si]
    mov bx, [si+2]
    mov cx, [si+4]
    mov dx, [si+6]

    not ax
    not bx
    not cx
    not dx
    add ax, 1
    adc bx, 0
    adc cx, 0
    adc dx, 0

    les di, [bp+10]     ; Res
    mov [es:di], ax
    mov [es:di+2], bx
    mov [es:di+4], cx
    mov [es:di+6], dx

    pop es
    pop di
    pop si
    pop ds
    pop bp
    retf 8

; ------------------------------------------------------------------------------
; S64MUL / U64MUL
; ------------------------------------------------------------------------------
S64MUL:
U64MUL:
    push bp
    mov bp, sp
    sub sp, 16          ; [bp-8]=Res, [bp-16]=B_Copy
    push ds
    push si
    push di
    push es

    ; Clear Result
    mov word [bp-8], 0
    mov word [bp-6], 0
    mov word [bp-4], 0
    mov word [bp-2], 0

    ; Load B to Stack
    lds si, [bp+6]
    mov ax, [si]
    mov [bp-16], ax
    mov ax, [si+2]
    mov [bp-14], ax
    mov ax, [si+4]
    mov [bp-12], ax
    mov ax, [si+6]
    mov [bp-10], ax

    ; Load A to Regs
    lds si, [bp+10]
    mov ax, [si]
    mov bx, [si+2]
    mov cx, [si+4]
    mov dx, [si+6]

    mov di, 64

.mul_loop:
    test ax, 1
    jz .mul_skip

    push ax
    mov ax, [bp-16]
    add [bp-8], ax
    mov ax, [bp-14]
    adc [bp-6], ax
    mov ax, [bp-12]
    adc [bp-4], ax
    mov ax, [bp-10]
    adc [bp-2], ax
    pop ax

.mul_skip:
    shr dx, 1
    rcr cx, 1
    rcr bx, 1
    rcr ax, 1

    shl word [bp-16], 1
    rcl word [bp-14], 1
    rcl word [bp-12], 1
    rcl word [bp-10], 1

    dec di
    jnz .mul_loop

    les di, [bp+14]
    mov ax, [bp-8]
    mov [es:di], ax
    mov ax, [bp-6]
    mov [es:di+2], ax
    mov ax, [bp-4]
    mov [es:di+4], ax
    mov ax, [bp-2]
    mov [es:di+6], ax

    pop es
    pop di
    pop si
    pop ds
    add sp, 16
    pop bp
    retf 12

; ------------------------------------------------------------------------------
; DIV_KERNEL_64
; ------------------------------------------------------------------------------
div_kernel_64:
    mov word [bp-8], 0
    mov word [bp-6], 0
    mov word [bp-4], 0
    mov word [bp-2], 0
    
    mov word [bp-16], 0
    mov word [bp-14], 0
    mov word [bp-12], 0
    mov word [bp-10], 0
    
    mov ax, [es:di]
    mov [bp-24], ax
    mov ax, [es:di+2]
    mov [bp-22], ax
    mov ax, [es:di+4]
    mov [bp-20], ax
    mov ax, [es:di+6]
    mov [bp-18], ax
    
    mov ax, [si]
    mov bx, [si+2]
    mov cx, [si+4]
    mov dx, [si+6]
    
    mov si, 64

.dk_loop:
    shl ax, 1
    rcl bx, 1
    rcl cx, 1
    rcl dx, 1
    
    rcl word [bp-16], 1
    rcl word [bp-14], 1
    rcl word [bp-12], 1
    rcl word [bp-10], 1
    
    shl word [bp-8], 1
    rcl word [bp-6], 1
    rcl word [bp-4], 1
    rcl word [bp-2], 1
    
    push ax
    
    mov ax, [bp-10]
    cmp ax, [bp-18]
    ja .dk_sub
    jb .dk_next
    mov ax, [bp-12]
    cmp ax, [bp-20]
    ja .dk_sub
    jb .dk_next
    mov ax, [bp-14]
    cmp ax, [bp-22]
    ja .dk_sub
    jb .dk_next
    mov ax, [bp-16]
    cmp ax, [bp-24]
    jb .dk_next

.dk_sub:
    mov ax, [bp-24]
    sub [bp-16], ax
    mov ax, [bp-22]
    sbb [bp-14], ax
    mov ax, [bp-20]
    sbb [bp-12], ax
    mov ax, [bp-18]
    sbb [bp-10], ax
    
    or word [bp-8], 1

.dk_next:
    pop ax
    dec si
    jnz .dk_loop
    
    ret

; ------------------------------------------------------------------------------
; U64DIV / U64MOD
; ------------------------------------------------------------------------------
U64DIV:
    push bp
    mov bp, sp
    sub sp, 24
    push ds
    push si
    push di
    push es

    lds si, [bp+10]
    les di, [bp+6]
    
    call div_kernel_64
    
    les di, [bp+14]
    mov ax, [bp-8]
    mov [es:di], ax
    mov ax, [bp-6]
    mov [es:di+2], ax
    mov ax, [bp-4]
    mov [es:di+4], ax
    mov ax, [bp-2]
    mov [es:di+6], ax

    pop es
    pop di
    pop si
    pop ds
    add sp, 24
    pop bp
    retf 12

U64MOD:
    push bp
    mov bp, sp
    sub sp, 24
    push ds
    push si
    push di
    push es

    lds si, [bp+10]
    les di, [bp+6]
    
    call div_kernel_64
    
    les di, [bp+14]
    mov ax, [bp-16]
    mov [es:di], ax
    mov ax, [bp-14]
    mov [es:di+2], ax
    mov ax, [bp-12]
    mov [es:di+4], ax
    mov ax, [bp-10]
    mov [es:di+6], ax

    pop es
    pop di
    pop si
    pop ds
    add sp, 24
    pop bp
    retf 12

S64DIV:
    jmp U64DIV
S64MOD:
    jmp U64MOD

; ------------------------------------------------------------------------------
; S64SHL / U64SHL
; ------------------------------------------------------------------------------
S64SHL:
U64SHL:
    push bp
    mov bp, sp
    push ds
    push si
    push di
    push es

    mov cx, [bp+6]
    and cx, 63
    
    lds si, [bp+8]
    mov ax, [si]
    mov bx, [si+2]
    push cx
    mov cx, [si+4]
    mov dx, [si+6]
    
    pop di
    or di, di
    jz shl_store_common ; Jump to GLOBAL label

.shl_loop:
    shl ax, 1
    rcl bx, 1
    rcl cx, 1
    rcl dx, 1
    dec di
    jnz .shl_loop

shl_store_common:       ; GLOBAL label
    les di, [bp+12]
    mov [es:di], ax
    mov [es:di+2], bx
    mov [es:di+4], cx
    mov [es:di+6], dx

    pop es
    pop di
    pop si
    pop ds
    pop bp
    retf 10

; ------------------------------------------------------------------------------
; S64SHR / U64SHR
; ------------------------------------------------------------------------------
S64SHR:
    push bp
    mov bp, sp
    push ds
    push si
    push di
    push es

    mov cx, [bp+6]
    and cx, 63
    
    lds si, [bp+8]
    mov ax, [si]
    mov bx, [si+2]
    push cx
    mov cx, [si+4]
    mov dx, [si+6]
    pop di

    or di, di
    jz shr_store_common

.sar_loop:
    sar dx, 1
    rcr cx, 1
    rcr bx, 1
    rcr ax, 1
    dec di
    jnz .sar_loop

    jmp shr_store_common

U64SHR:
    push bp
    mov bp, sp
    push ds
    push si
    push di
    push es

    mov cx, [bp+6]
    and cx, 63
    
    lds si, [bp+8]
    mov ax, [si]
    mov bx, [si+2]
    push cx
    mov cx, [si+4]
    mov dx, [si+6]
    pop di

    or di, di
    jz shr_store_common

.shr_loop:
    shr dx, 1
    rcr cx, 1
    rcr bx, 1
    rcr ax, 1
    dec di
    jnz .shr_loop

shr_store_common:       ; GLOBAL label
    les di, [bp+12]
    mov [es:di], ax
    mov [es:di+2], bx
    mov [es:di+4], cx
    mov [es:di+6], dx

    pop es
    pop di
    pop si
    pop ds
    pop bp
    retf 10

; ------------------------------------------------------------------------------
; S64CMP
; ------------------------------------------------------------------------------
S64CMP:
    push bp
    mov bp, sp
    push ds
    push si
    push es
    push di

    lds si, [bp+10]
    les di, [bp+6]
    
    mov ax, [si+6]
    mov dx, [es:di+6]
    cmp ax, dx
    jl .cmp_less
    jg .cmp_greater
    
    mov ax, [si+4]
    mov dx, [es:di+4]
    cmp ax, dx
    jb .cmp_less
    ja .cmp_greater
    
    mov ax, [si+2]
    mov dx, [es:di+2]
    cmp ax, dx
    jb .cmp_less
    ja .cmp_greater
    
    mov ax, [si]
    mov dx, [es:di]
    cmp ax, dx
    jb .cmp_less
    ja .cmp_greater
    
    xor ax, ax
    jmp cmp_done_common

.cmp_less:
    mov ax, -1
    jmp cmp_done_common
.cmp_greater:
    mov ax, 1
    jmp cmp_done_common

; ------------------------------------------------------------------------------
; U64CMP
; ------------------------------------------------------------------------------
U64CMP:
    push bp
    mov bp, sp
    push ds
    push si
    push es
    push di

    lds si, [bp+10]
    les di, [bp+6]
    
    mov ax, [si+6]
    mov dx, [es:di+6]
    cmp ax, dx
    jb .u_less
    ja .u_greater
    
    mov ax, [si+4]
    mov dx, [es:di+4]
    cmp ax, dx
    jb .u_less
    ja .u_greater
    
    mov ax, [si+2]
    mov dx, [es:di+2]
    cmp ax, dx
    jb .u_less
    ja .u_greater
    
    mov ax, [si]
    mov dx, [es:di]
    cmp ax, dx
    jb .u_less
    ja .u_greater
    
    xor ax, ax
    jmp cmp_done_common

.u_less:
    mov ax, -1
    jmp cmp_done_common
.u_greater:
    mov ax, 1

cmp_done_common:        ; GLOBAL label for shared exit
    pop di
    pop es
    pop si
    pop ds
    pop bp
    retf 8

; ------------------------------------------------------------------------------
; S64TOA / U64TOA
; ------------------------------------------------------------------------------
S64TOA:
    push bp
    mov bp, sp
    sub sp, 8
    push ds
    push si
    push di
    push es

    les di, [bp+6]      ; Buffer
    lds si, [bp+10]     ; Val
    
    ; Check Sign
    mov dx, [si+6]
    test dx, 8000h
    jz .s_pos

    ; Negative
    mov byte [es:di], '-'
    inc di
    
    ; Copy and Negate to Local
    mov ax, [si]
    not ax
    mov [bp-8], ax
    mov ax, [si+2]
    not ax
    mov [bp-6], ax
    mov ax, [si+4]
    not ax
    mov [bp-4], ax
    mov ax, dx
    not ax
    mov [bp-2], ax
    
    add word [bp-8], 1
    adc word [bp-6], 0
    adc word [bp-4], 0
    adc word [bp-2], 0
    
    jmp toa_convert_start

.s_pos:
    ; Copy to Local
    mov ax, [si]
    mov [bp-8], ax
    mov ax, [si+2]
    mov [bp-6], ax
    mov ax, [si+4]
    mov [bp-4], ax
    mov ax, dx
    mov [bp-2], ax

    jmp toa_convert_start

U64TOA:
    push bp
    mov bp, sp
    sub sp, 8
    push ds
    push si
    push di
    push es
    
    lds si, [bp+10]
    mov ax, [si]
    mov [bp-8], ax
    mov ax, [si+2]
    mov [bp-6], ax
    mov ax, [si+4]
    mov [bp-4], ax
    mov ax, [si+6]
    mov [bp-2], ax
    
    les di, [bp+6]

toa_convert_start:      ; GLOBAL label
    ; Check Zero
    mov ax, [bp-8]
    or ax, [bp-6]
    or ax, [bp-4]
    or ax, [bp-2]
    jnz .toa_not_zero
    
    mov byte [es:di], '0'
    inc di
    mov byte [es:di], 0
    jmp toa_exit_common

.toa_not_zero:
    xor cx, cx

.toa_loop:
    call local_div10
    add bl, '0'
    push bx
    inc cx
    
    mov ax, [bp-8]
    or ax, [bp-6]
    or ax, [bp-4]
    or ax, [bp-2]
    jnz .toa_loop

.toa_pop:
    pop ax
    stosb
    loop .toa_pop
    mov byte [es:di], 0

toa_exit_common:        ; GLOBAL label
    pop es
    pop di
    pop si
    pop ds
    add sp, 8
    pop bp
    retf 8

; Helper for TOA
local_div10:
    push si
    mov si, 10
    xor dx, dx
    
    mov ax, [bp-2]
    div si
    mov [bp-2], ax
    
    mov ax, [bp-4]
    div si
    mov [bp-4], ax
    
    mov ax, [bp-6]
    div si
    mov [bp-6], ax
    
    mov ax, [bp-8]
    div si
    mov [bp-8], ax
    
    mov bx, dx
    pop si
    ret

