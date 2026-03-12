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
; Calling Convention: Pascal FAR CALL (VAR params = Pointers)
; ==============================================================================
;
%include "lmath.inc"
;
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

S64ADD:
U64ADD:
    push bp
    mov bp, sp
    %define op1_off bp+RSIZE+6
    %define op1_seg bp+RSIZE+8
    %define op2_off bp+RSIZE+2
    %define op2_seg bp+RSIZE+4
    %define res_off bp+RSIZE+10
    %define res_seg bp+RSIZE+12
    push ds
    push es
    push si
    push di
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si]
    mov bx, [si+2]
    mov cx, [si+4]
    mov dx, [si+6]
    mov si, [op2_off]
    mov ds, [op2_seg]
    add ax, [si]
    adc bx, [si+2]
    adc cx, [si+4]
    adc dx, [si+6]
    mov di, [res_off]
    mov es, [res_seg]
    mov [es:di], ax
    mov [es:di+2], bx
    mov [es:di+4], cx
    mov [es:di+6], dx
    pop di
    pop si
    pop es
    pop ds
    %undef op1_off
    %undef op1_seg
    %undef op2_off
    %undef op2_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 12

S64SUB:
U64SUB:
    push bp
    mov bp, sp
    %define op1_off bp+RSIZE+6
    %define op1_seg bp+RSIZE+8
    %define op2_off bp+RSIZE+2
    %define op2_seg bp+RSIZE+4
    %define res_off bp+RSIZE+10
    %define res_seg bp+RSIZE+12
    push ds
    push es
    push si
    push di
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si]
    mov bx, [si+2]
    mov cx, [si+4]
    mov dx, [si+6]
    mov si, [op2_off]
    mov ds, [op2_seg]
    sub ax, [si]
    sbb bx, [si+2]
    sbb cx, [si+4]
    sbb dx, [si+6]
    mov di, [res_off]
    mov es, [res_seg]
    mov [es:di], ax
    mov [es:di+2], bx
    mov [es:di+4], cx
    mov [es:di+6], dx
    pop di
    pop si
    pop es
    pop ds
    %undef op1_off
    %undef op1_seg
    %undef op2_off
    %undef op2_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 12

S64NEG:
    push bp
    mov bp, sp
    %define op_off bp+RSIZE+2
    %define op_seg bp+RSIZE+4
    %define res_off bp+RSIZE+6
    %define res_seg bp+RSIZE+8
    push ds
    push es
    push si
    push di
    mov si, [op_off]
    mov ds, [op_seg]
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
    mov di, [res_off]
    mov es, [res_seg]
    mov [es:di], ax
    mov [es:di+2], bx
    mov [es:di+4], cx
    mov [es:di+6], dx
    pop di
    pop si
    pop es
    pop ds
    %undef op_off
    %undef op_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 8

U64MUL:
    push bp
    mov bp, sp
    %define op1_off bp+RSIZE+6
    %define op1_seg bp+RSIZE+8
    %define op2_off bp+RSIZE+2
    %define op2_seg bp+RSIZE+4
    %define res_off bp+RSIZE+10
    %define res_seg bp+RSIZE+12
    sub sp, 32
    push ds
    push es
    push si
    push di
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si]
    mov [bp-16], ax
    mov ax, [si+2]
    mov [bp-14], ax
    mov ax, [si+4]
    mov [bp-12], ax
    mov ax, [si+6]
    mov [bp-10], ax
    mov si, [op2_off]
    mov ds, [op2_seg]
    mov ax, [si]
    mov [bp-24], ax
    mov ax, [si+2]
    mov [bp-22], ax
    mov ax, [si+4]
    mov [bp-20], ax
    mov ax, [si+6]
    mov [bp-18], ax
    xor ax, ax
    mov [bp-32], ax
    mov [bp-30], ax
    mov [bp-28], ax
    mov [bp-26], ax
    mov cx, 64
.mul_loop:
    test word [bp-16], 1
    jz .mul_skip
    mov ax, [bp-24]
    add [bp-32], ax
    mov ax, [bp-22]
    adc [bp-30], ax
    mov ax, [bp-20]
    adc [bp-28], ax
    mov ax, [bp-18]
    adc [bp-26], ax
.mul_skip:
    shr word [bp-10], 1
    rcr word [bp-12], 1
    rcr word [bp-14], 1
    rcr word [bp-16], 1
    shl word [bp-24], 1
    rcl word [bp-22], 1
    rcl word [bp-20], 1
    rcl word [bp-18], 1
    loop .mul_loop
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-32]
    mov [es:di], ax
    mov ax, [bp-30]
    mov [es:di+2], ax
    mov ax, [bp-28]
    mov [es:di+4], ax
    mov ax, [bp-26]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 32
    %undef op1_off
    %undef op1_seg
    %undef op2_off
    %undef op2_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 12

S64MUL:
    push bp
    mov bp, sp
    %define op1_off bp+RSIZE+6
    %define op1_seg bp+RSIZE+8
    %define op2_off bp+RSIZE+2
    %define op2_seg bp+RSIZE+4
    %define res_off bp+RSIZE+10
    %define res_seg bp+RSIZE+12
    sub sp, 40
    push ds
    push es
    push si
    push di
    xor bx, bx
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si+6]
    test ax, 8000h
    jz .a_pos
    inc bx
.a_pos:
    mov si, [op2_off]
    mov ds, [op2_seg]
    mov ax, [si+6]
    test ax, 8000h
    jz .b_pos
    xor bx, 1
.b_pos:
    mov [bp-2], bx
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si]
    mov [bp-16], ax
    mov ax, [si+2]
    mov [bp-14], ax
    mov ax, [si+4]
    mov [bp-12], ax
    mov ax, [si+6]
    mov [bp-10], ax
    test ax, 8000h
    jz .abs_a_done
    not word [bp-16]
    not word [bp-14]
    not word [bp-12]
    not word [bp-10]
    add word [bp-16], 1
    adc word [bp-14], 0
    adc word [bp-12], 0
    adc word [bp-10], 0
.abs_a_done:
    mov si, [op2_off]
    mov ds, [op2_seg]
    mov ax, [si]
    mov [bp-24], ax
    mov ax, [si+2]
    mov [bp-22], ax
    mov ax, [si+4]
    mov [bp-20], ax
    mov ax, [si+6]
    mov [bp-18], ax
    test ax, 8000h
    jz .abs_b_done
    not word [bp-24]
    not word [bp-22]
    not word [bp-20]
    not word [bp-18]
    add word [bp-24], 1
    adc word [bp-22], 0
    adc word [bp-20], 0
    adc word [bp-18], 0
.abs_b_done:
    xor ax, ax
    mov [bp-32], ax
    mov [bp-30], ax
    mov [bp-28], ax
    mov [bp-26], ax
    mov cx, 64
.smul_loop:
    test word [bp-16], 1
    jz .smul_skip
    mov ax, [bp-24]
    add [bp-32], ax
    mov ax, [bp-22]
    adc [bp-30], ax
    mov ax, [bp-20]
    adc [bp-28], ax
    mov ax, [bp-18]
    adc [bp-26], ax
.smul_skip:
    shr word [bp-10], 1
    rcr word [bp-12], 1
    rcr word [bp-14], 1
    rcr word [bp-16], 1
    shl word [bp-24], 1
    rcl word [bp-22], 1
    rcl word [bp-20], 1
    rcl word [bp-18], 1
    loop .smul_loop
    cmp word [bp-2], 0
    je .store_smul
    not word [bp-32]
    not word [bp-30]
    not word [bp-28]
    not word [bp-26]
    add word [bp-32], 1
    adc word [bp-30], 0
    adc word [bp-28], 0
    adc word [bp-26], 0
.store_smul:
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-32]
    mov [es:di], ax
    mov ax, [bp-30]
    mov [es:di+2], ax
    mov ax, [bp-28]
    mov [es:di+4], ax
    mov ax, [bp-26]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 40
    %undef op1_off
    %undef op1_seg
    %undef op2_off
    %undef op2_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 12

U64DIV:
    push bp
    mov bp, sp
    %define op1_off bp+RSIZE+6
    %define op1_seg bp+RSIZE+8
    %define op2_off bp+RSIZE+2
    %define op2_seg bp+RSIZE+4
    %define res_off bp+RSIZE+10
    %define res_seg bp+RSIZE+12
    sub sp, 40
    push ds
    push es
    push si
    push di
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si]
    mov [bp-16], ax
    mov ax, [si+2]
    mov [bp-14], ax
    mov ax, [si+4]
    mov [bp-12], ax
    mov ax, [si+6]
    mov [bp-10], ax
    mov si, [op2_off]
    mov ds, [op2_seg]
    mov ax, [si]
    mov [bp-24], ax
    mov ax, [si+2]
    mov [bp-22], ax
    mov ax, [si+4]
    mov [bp-20], ax
    mov ax, [si+6]
    mov [bp-18], ax
    xor ax, ax
    mov [bp-32], ax
    mov [bp-30], ax
    mov [bp-28], ax
    mov [bp-26], ax
    mov cx, 64
.udiv_loop:
    shl word [bp-16], 1
    rcl word [bp-14], 1
    rcl word [bp-12], 1
    rcl word [bp-10], 1
    rcl word [bp-32], 1
    rcl word [bp-30], 1
    rcl word [bp-28], 1
    rcl word [bp-26], 1
    push cx
    mov ax, [bp-32]
    sub ax, [bp-24]
    mov ax, [bp-30]
    sbb ax, [bp-22]
    mov ax, [bp-28]
    sbb ax, [bp-20]
    mov ax, [bp-26]
    sbb ax, [bp-18]
    pop cx
    jc .udiv_next
    mov ax, [bp-24]
    sub [bp-32], ax
    mov ax, [bp-22]
    sbb [bp-30], ax
    mov ax, [bp-20]
    sbb [bp-28], ax
    mov ax, [bp-18]
    sbb [bp-26], ax
    or word [bp-16], 1
.udiv_next:
    loop .udiv_loop
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-16]
    mov [es:di], ax
    mov ax, [bp-14]
    mov [es:di+2], ax
    mov ax, [bp-12]
    mov [es:di+4], ax
    mov ax, [bp-10]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 40
    %undef op1_off
    %undef op1_seg
    %undef op2_off
    %undef op2_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 12

U64MOD:
    push bp
    mov bp, sp
    %define op1_off bp+RSIZE+6
    %define op1_seg bp+RSIZE+8
    %define op2_off bp+RSIZE+2
    %define op2_seg bp+RSIZE+4
    %define res_off bp+RSIZE+10
    %define res_seg bp+RSIZE+12
    sub sp, 40
    push ds
    push es
    push si
    push di
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si]
    mov [bp-16], ax
    mov ax, [si+2]
    mov [bp-14], ax
    mov ax, [si+4]
    mov [bp-12], ax
    mov ax, [si+6]
    mov [bp-10], ax
    mov si, [op2_off]
    mov ds, [op2_seg]
    mov ax, [si]
    mov [bp-24], ax
    mov ax, [si+2]
    mov [bp-22], ax
    mov ax, [si+4]
    mov [bp-20], ax
    mov ax, [si+6]
    mov [bp-18], ax
    xor ax, ax
    mov [bp-32], ax
    mov [bp-30], ax
    mov [bp-28], ax
    mov [bp-26], ax
    mov cx, 64
.umod_loop:
    shl word [bp-16], 1
    rcl word [bp-14], 1
    rcl word [bp-12], 1
    rcl word [bp-10], 1
    rcl word [bp-32], 1
    rcl word [bp-30], 1
    rcl word [bp-28], 1
    rcl word [bp-26], 1
    push cx
    mov ax, [bp-32]
    sub ax, [bp-24]
    mov ax, [bp-30]
    sbb ax, [bp-22]
    mov ax, [bp-28]
    sbb ax, [bp-20]
    mov ax, [bp-26]
    sbb ax, [bp-18]
    pop cx
    jc .umod_next
    mov ax, [bp-24]
    sub [bp-32], ax
    mov ax, [bp-22]
    sbb [bp-30], ax
    mov ax, [bp-20]
    sbb [bp-28], ax
    mov ax, [bp-18]
    sbb [bp-26], ax
    or word [bp-16], 1
.umod_next:
    loop .umod_loop
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-32]
    mov [es:di], ax
    mov ax, [bp-30]
    mov [es:di+2], ax
    mov ax, [bp-28]
    mov [es:di+4], ax
    mov ax, [bp-26]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 40
    %undef op1_off
    %undef op1_seg
    %undef op2_off
    %undef op2_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 12

S64DIV:
    push bp
    mov bp, sp
    %define op1_off bp+RSIZE+6
    %define op1_seg bp+RSIZE+8
    %define op2_off bp+RSIZE+2
    %define op2_seg bp+RSIZE+4
    %define res_off bp+RSIZE+10
    %define res_seg bp+RSIZE+12
    sub sp, 48
    push ds
    push es
    push si
    push di
    xor bx, bx
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si+6]
    test ax, 8000h
    jz .a_pos_div
    inc bx
.a_pos_div:
    mov si, [op2_off]
    mov ds, [op2_seg]
    mov ax, [si+6]
    test ax, 8000h
    jz .b_pos_div
    xor bx, 1
.b_pos_div:
    mov [bp-2], bx
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si]
    mov [bp-16], ax
    mov ax, [si+2]
    mov [bp-14], ax
    mov ax, [si+4]
    mov [bp-12], ax
    mov ax, [si+6]
    mov [bp-10], ax
    test ax, 8000h
    jz .abs_a_done_div
    not word [bp-16]
    not word [bp-14]
    not word [bp-12]
    not word [bp-10]
    add word [bp-16], 1
    adc word [bp-14], 0
    adc word [bp-12], 0
    adc word [bp-10], 0
.abs_a_done_div:
    mov si, [op2_off]
    mov ds, [op2_seg]
    mov ax, [si]
    mov [bp-24], ax
    mov ax, [si+2]
    mov [bp-22], ax
    mov ax, [si+4]
    mov [bp-20], ax
    mov ax, [si+6]
    mov [bp-18], ax
    test ax, 8000h
    jz .abs_b_done_div
    not word [bp-24]
    not word [bp-22]
    not word [bp-20]
    not word [bp-18]
    add word [bp-24], 1
    adc word [bp-22], 0
    adc word [bp-20], 0
    adc word [bp-18], 0
.abs_b_done_div:
    xor ax, ax
    mov [bp-32], ax
    mov [bp-30], ax
    mov [bp-28], ax
    mov [bp-26], ax
    mov cx, 64
.sdiv_abs_loop:
    shl word [bp-16], 1
    rcl word [bp-14], 1
    rcl word [bp-12], 1
    rcl word [bp-10], 1
    rcl word [bp-32], 1
    rcl word [bp-30], 1
    rcl word [bp-28], 1
    rcl word [bp-26], 1
    push cx
    mov ax, [bp-32]
    sub ax, [bp-24]
    mov ax, [bp-30]
    sbb ax, [bp-22]
    mov ax, [bp-28]
    sbb ax, [bp-20]
    mov ax, [bp-26]
    sbb ax, [bp-18]
    pop cx
    jc .sdiv_abs_next
    mov ax, [bp-24]
    sub [bp-32], ax
    mov ax, [bp-22]
    sbb [bp-30], ax
    mov ax, [bp-20]
    sbb [bp-28], ax
    mov ax, [bp-18]
    sbb [bp-26], ax
    or word [bp-16], 1
.sdiv_abs_next:
    loop .sdiv_abs_loop
    cmp word [bp-2], 0
    je .quot_pos
    not word [bp-16]
    not word [bp-14]
    not word [bp-12]
    not word [bp-10]
    add word [bp-16], 1
    adc word [bp-14], 0
    adc word [bp-12], 0
    adc word [bp-10], 0
.quot_pos:
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-16]
    mov [es:di], ax
    mov ax, [bp-14]
    mov [es:di+2], ax
    mov ax, [bp-12]
    mov [es:di+4], ax
    mov ax, [bp-10]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 48
    %undef op1_off
    %undef op1_seg
    %undef op2_off
    %undef op2_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 12

S64MOD:
    push bp
    mov bp, sp
    %define op1_off bp+RSIZE+6
    %define op1_seg bp+RSIZE+8
    %define op2_off bp+RSIZE+2
    %define op2_seg bp+RSIZE+4
    %define res_off bp+RSIZE+10
    %define res_seg bp+RSIZE+12
    sub sp, 48
    push ds
    push es
    push si
    push di
    mov si, [op1_off]
    mov ds, [op1_seg]
    mov ax, [si+6]
    and ax, 8000h
    mov [bp-4], ax
    mov ax, [si]
    mov [bp-16], ax
    mov ax, [si+2]
    mov [bp-14], ax
    mov ax, [si+4]
    mov [bp-12], ax
    mov ax, [si+6]
    mov [bp-10], ax
    test ax, 8000h
    jz .abs_a_done_mod
    not word [bp-16]
    not word [bp-14]
    not word [bp-12]
    not word [bp-10]
    add word [bp-16], 1
    adc word [bp-14], 0
    adc word [bp-12], 0
    adc word [bp-10], 0
.abs_a_done_mod:
    mov si, [op2_off]
    mov ds, [op2_seg]
    mov ax, [si]
    mov [bp-24], ax
    mov ax, [si+2]
    mov [bp-22], ax
    mov ax, [si+4]
    mov [bp-20], ax
    mov ax, [si+6]
    mov [bp-18], ax
    test ax, 8000h
    jz .abs_b_done_mod
    not word [bp-24]
    not word [bp-22]
    not word [bp-20]
    not word [bp-18]
    add word [bp-24], 1
    adc word [bp-22], 0
    adc word [bp-20], 0
    adc word [bp-18], 0
.abs_b_done_mod:
    xor ax, ax
    mov [bp-32], ax
    mov [bp-30], ax
    mov [bp-28], ax
    mov [bp-26], ax
    mov cx, 64
.smod_abs_loop:
    shl word [bp-16], 1
    rcl word [bp-14], 1
    rcl word [bp-12], 1
    rcl word [bp-10], 1
    rcl word [bp-32], 1
    rcl word [bp-30], 1
    rcl word [bp-28], 1
    rcl word [bp-26], 1
    push cx
    mov ax, [bp-32]
    sub ax, [bp-24]
    mov ax, [bp-30]
    sbb ax, [bp-22]
    mov ax, [bp-28]
    sbb ax, [bp-20]
    mov ax, [bp-26]
    sbb ax, [bp-18]
    pop cx
    jc .smod_abs_next
    mov ax, [bp-24]
    sub [bp-32], ax
    mov ax, [bp-22]
    sbb [bp-30], ax
    mov ax, [bp-20]
    sbb [bp-28], ax
    mov ax, [bp-18]
    sbb [bp-26], ax
    or word [bp-16], 1
.smod_abs_next:
    loop .smod_abs_loop
    cmp word [bp-4], 0
    je .rem_pos
    not word [bp-32]
    not word [bp-30]
    not word [bp-28]
    not word [bp-26]
    add word [bp-32], 1
    adc word [bp-30], 0
    adc word [bp-28], 0
    adc word [bp-26], 0
.rem_pos:
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-32]
    mov [es:di], ax
    mov ax, [bp-30]
    mov [es:di+2], ax
    mov ax, [bp-28]
    mov [es:di+4], ax
    mov ax, [bp-26]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 48
    %undef op1_off
    %undef op1_seg
    %undef op2_off
    %undef op2_seg
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 12

S64SHL:
U64SHL:
    push bp
    mov bp, sp
    %define op_off bp+RSIZE+4
    %define op_seg bp+RSIZE+6
    %define count  bp+RSIZE+2
    %define res_off bp+RSIZE+8
    %define res_seg bp+RSIZE+10
    sub sp, 8
    push ds
    push es
    push si
    push di
    mov si, [op_off]
    mov ds, [op_seg]
    mov ax, [si]
    mov [bp-8], ax
    mov ax, [si+2]
    mov [bp-6], ax
    mov ax, [si+4]
    mov [bp-4], ax
    mov ax, [si+6]
    mov [bp-2], ax
    mov cx, [count]
    and cx, 63
    jz .shl_done
.shl_loop:
    shl word [bp-8], 1
    rcl word [bp-6], 1
    rcl word [bp-4], 1
    rcl word [bp-2], 1
    loop .shl_loop
.shl_done:
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-8]
    mov [es:di], ax
    mov ax, [bp-6]
    mov [es:di+2], ax
    mov ax, [bp-4]
    mov [es:di+4], ax
    mov ax, [bp-2]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 8
    %undef op_off
    %undef op_seg
    %undef count
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 10

S64SHR:
    push bp
    mov bp, sp
    %define op_off bp+RSIZE+4
    %define op_seg bp+RSIZE+6
    %define count  bp+RSIZE+2
    %define res_off bp+RSIZE+8
    %define res_seg bp+RSIZE+10
    sub sp, 8
    push ds
    push es
    push si
    push di
    mov si, [op_off]
    mov ds, [op_seg]
    mov ax, [si]
    mov [bp-8], ax
    mov ax, [si+2]
    mov [bp-6], ax
    mov ax, [si+4]
    mov [bp-4], ax
    mov ax, [si+6]
    mov [bp-2], ax
    mov cx, [count]
    and cx, 63
    jz .asar_done
.asar_loop:
    sar word [bp-2], 1
    rcr word [bp-4], 1
    rcr word [bp-6], 1
    rcr word [bp-8], 1
    loop .asar_loop
.asar_done:
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-8]
    mov [es:di], ax
    mov ax, [bp-6]
    mov [es:di+2], ax
    mov ax, [bp-4]
    mov [es:di+4], ax
    mov ax, [bp-2]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 8
    %undef op_off
    %undef op_seg
    %undef count
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 10

U64SHR:
    push bp
    mov bp, sp
    %define op_off bp+RSIZE+4
    %define op_seg bp+RSIZE+6
    %define count  bp+RSIZE+2
    %define res_off bp+RSIZE+8
    %define res_seg bp+RSIZE+10
    sub sp, 8
    push ds
    push es
    push si
    push di
    mov si, [op_off]
    mov ds, [op_seg]
    mov ax, [si]
    mov [bp-8], ax
    mov ax, [si+2]
    mov [bp-6], ax
    mov ax, [si+4]
    mov [bp-4], ax
    mov ax, [si+6]
    mov [bp-2], ax
    mov cx, [count]
    and cx, 63
    jz .ushr_done
.ushr_loop:
    shr word [bp-2], 1
    rcr word [bp-4], 1
    rcr word [bp-6], 1
    rcr word [bp-8], 1
    loop .ushr_loop
.ushr_done:
    mov di, [res_off]
    mov es, [res_seg]
    mov ax, [bp-8]
    mov [es:di], ax
    mov ax, [bp-6]
    mov [es:di+2], ax
    mov ax, [bp-4]
    mov [es:di+4], ax
    mov ax, [bp-2]
    mov [es:di+6], ax
    pop di
    pop si
    pop es
    pop ds
    add sp, 8
    %undef op_off
    %undef op_seg
    %undef count
    %undef res_off
    %undef res_seg
    pop bp
    RETMACRO 10

S64CMP:
    push bp
    mov bp, sp
    %define ptr1_off bp+RSIZE+6
    %define ptr1_seg bp+RSIZE+8
    %define ptr2_off bp+RSIZE+2
    %define ptr2_seg bp+RSIZE+4
    push ds
    push es
    push si
    push di
    mov si, [ptr1_off]
    mov ds, [ptr1_seg]
    mov di, [ptr2_off]
    mov es, [ptr2_seg]
    mov ax, [si+6]
    cmp ax, [es:di+6]
    jl .less
    jg .greater
    mov ax, [si+4]
    cmp ax, [es:di+4]
    jb .less
    ja .greater
    mov ax, [si+2]
    cmp ax, [es:di+2]
    jb .less
    ja .greater
    mov ax, [si]
    cmp ax, [es:di]
    jb .less
    ja .greater
    xor ax, ax
    jmp .done
.less:
    mov ax, -1
    jmp .done
.greater:
    mov ax, 1
.done:
    pop di
    pop si
    pop es
    pop ds
    %undef ptr1_off
    %undef ptr1_seg
    %undef ptr2_off
    %undef ptr2_seg
    pop bp
    RETMACRO 8

U64CMP:
    push bp
    mov bp, sp
    %define ptr1_off bp+RSIZE+6
    %define ptr1_seg bp+RSIZE+8
    %define ptr2_off bp+RSIZE+2
    %define ptr2_seg bp+RSIZE+4
    push ds
    push es
    push si
    push di
    mov si, [ptr1_off]
    mov ds, [ptr1_seg]
    mov di, [ptr2_off]
    mov es, [ptr2_seg]
    mov ax, [si+6]
    cmp ax, [es:di+6]
    jb .less
    ja .greater
    mov ax, [si+4]
    cmp ax, [es:di+4]
    jb .less
    ja .greater
    mov ax, [si+2]
    cmp ax, [es:di+2]
    jb .less
    ja .greater
    mov ax, [si]
    cmp ax, [es:di]
    jb .less
    ja .greater
    xor ax, ax
    jmp .done
.less:
    mov ax, -1
    jmp .done
.greater:
    mov ax, 1
.done:
    pop di
    pop si
    pop es
    pop ds
    %undef ptr1_off
    %undef ptr1_seg
    %undef ptr2_off
    %undef ptr2_seg
    pop bp
    RETMACRO 8

S64TOA:
    push bp
    mov bp, sp
    %define ptr_off bp+RSIZE+6
    %define ptr_seg bp+RSIZE+8
    %define buf_off bp+RSIZE+2
    %define buf_seg bp+RSIZE+4
    mov ax, 1
    push ax
    %undef ptr_off
    %undef ptr_seg
    %undef buf_off
    %undef buf_seg
    jmp toa_common

U64TOA:
    push bp
    mov bp, sp
    %define ptr_off bp+RSIZE+6
    %define ptr_seg bp+RSIZE+8
    %define buf_off bp+RSIZE+2
    %define buf_seg bp+RSIZE+4
    xor ax, ax
    push ax
    %undef ptr_off
    %undef ptr_seg
    %undef buf_off
    %undef buf_seg
    jmp toa_common

toa_common:
    %define ptr_off bp+RSIZE+6
    %define ptr_seg bp+RSIZE+8
    %define buf_off bp+RSIZE+2
    %define buf_seg bp+RSIZE+4
    sub sp, 8
    push ds
    push es
    push si
    push di
    mov si, [ptr_off]
    mov ds, [ptr_seg]
    mov ax, [si]
    mov [bp-10], ax
    mov ax, [si+2]
    mov [bp-8], ax
    mov ax, [si+4]
    mov [bp-6], ax
    mov ax, [si+6]
    mov [bp-4], ax
    mov di, [buf_off]
    mov es, [buf_seg]
    cmp word [bp-2], 1
    jne .conv_unsigned
    test word [bp-4], 8000h
    jz .conv_unsigned
    mov byte [es:di], '-'
    inc di
    not word [bp-10]
    not word [bp-8]
    not word [bp-6]
    not word [bp-4]
    add word [bp-10], 1
    adc word [bp-8], 0
    adc word [bp-6], 0
    adc word [bp-4], 0
.conv_unsigned:
    mov ax, [bp-10]
    or ax, [bp-8]
    or ax, [bp-6]
    or ax, [bp-4]
    jnz .not_zero
    mov word [es:di], '0'
    mov byte [es:di+1], 0
    jmp .exit
.not_zero:
    xor cx, cx
    mov bx, 10
.div_loop:
    xor dx, dx
    mov ax, [bp-4]
    div bx
    mov [bp-4], ax
    mov ax, [bp-6]
    div bx
    mov [bp-6], ax
    mov ax, [bp-8]
    div bx
    mov [bp-8], ax
    mov ax, [bp-10]
    div bx
    mov [bp-10], ax
    add dl, '0'
    push dx
    inc cx
    mov ax, [bp-10]
    or ax, [bp-8]
    or ax, [bp-6]
    or ax, [bp-4]
    jnz .div_loop
.store_digits:
    pop ax
    stosb
    loop .store_digits
    mov byte [es:di], 0
.exit:
    pop di
    pop si
    pop es
    pop ds
    add sp, 10
    %undef ptr_off
    %undef ptr_seg
    %undef buf_off
    %undef buf_seg
    pop bp
    RETMACRO 8








