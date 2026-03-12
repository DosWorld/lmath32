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
; MATH32 LIBRARY FOR TURBO PASCAL (16-BIT)
; Calling Convention: Pascal FAR CALL
; ==============================================================================
;
%include "lmath.inc"
;
; ==============================================================================
; EXPORTED SYMBOLS (UPPERCASE for Turbo Pascal linker)
; ==============================================================================
;
global S32ADD, U32ADD
global S32SUB, U32SUB
global S32MUL, U32MUL
global S32DIV, U32DIV
global S32MOD, U32MOD
global S32SHL, U32SHL
global U32SHR, S32SHR
global S32CMP, U32CMP
global S32TOA, U32TOA
global S32NEG

S32TOA:
    push bp
    mov bp, sp
    %define buf_off bp+RSIZE+2
    %define buf_seg bp+RSIZE+4
    %define val_low bp+RSIZE+6
    %define val_high bp+RSIZE+8
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, [buf_seg]
    mov es, ax
    mov di, [buf_off]

    mov dx, [val_high]
    mov ax, [val_low]

    test dx, dx
    jns .is_positive

    mov byte [es:di], '-'
    inc di
    
    not dx
    not ax
    add ax, 1
    adc dx, 0

.is_positive:
    call u32toa_internal

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    %undef buf_off
    %undef buf_seg
    %undef val_low
    %undef val_high
    pop bp
    RETMACRO 8

U32TOA:
    push bp
    mov bp, sp
    %define buf_off bp+RSIZE+2
    %define buf_seg bp+RSIZE+4
    %define val_low bp+RSIZE+6
    %define val_high bp+RSIZE+8
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, [buf_seg]
    mov es, ax
    mov di, [buf_off]

    mov dx, [val_high]
    mov ax, [val_low]

    call u32toa_internal

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    %undef buf_off
    %undef buf_seg
    %undef val_low
    %undef val_high
    pop bp
    RETMACRO 8

u32toa_internal:
    mov bx, dx
    or bx, ax
    jnz .convert
    
    mov byte [es:di], '0'
    inc di
    mov byte [es:di], 0
    ret

.convert:
    xor cx, cx

.loop_div:
    push cx
    call local_div_10
    pop cx
    
    add bl, '0'
    push bx
    inc cx
    
    mov si, dx
    or si, ax
    jnz .loop_div

.write_loop:
    pop ax
    stosb
    dec cx
    jnz .write_loop

    mov byte [es:di], 0
    ret

local_div_10:
    mov cx, 10
    push ax
    mov ax, dx
    xor dx, dx
    div cx
    mov bx, ax
    pop ax
    div cx
    
    mov cx, dx
    mov dx, bx
    mov bx, cx
    ret

div_kernel_32:
    push bp
    push si
    push di
    
    mov si, cx
    or si, bx
    jz .div_by_zero

    mov si, cx
    mov di, bx
    xor cx, cx
    xor bx, bx
    mov bp, 32

.div_loop:
    shl ax, 1
    rcl dx, 1
    rcl bx, 1
    rcl cx, 1
    
    cmp cx, si
    jb .next_bit
    ja .sub_div
    cmp bx, di
    jb .next_bit

.sub_div:
    sub bx, di
    sbb cx, si
    inc ax 

.next_bit:
    dec bp
    jnz .div_loop
    jmp .done

.div_by_zero:
    mov dx, 0FFFFh
    mov ax, 0FFFFh
    mov cx, dx
    mov bx, ax

.done:
    pop di
    pop si
    pop bp
    ret

S32CMP:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    mov dx, [a_high]
    cmp dx, [b_high]
    jl  cmp_ret_minus
    jg  cmp_ret_plus
    mov ax, [a_low]
    cmp ax, [b_low]
    jb  cmp_ret_minus
    ja  cmp_ret_plus
    jmp cmp_ret_zero

U32CMP:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    mov dx, [a_high]
    cmp dx, [b_high]
    jb  cmp_ret_minus
    ja  cmp_ret_plus
    mov ax, [a_low]
    cmp ax, [b_low]
    jb  cmp_ret_minus
    ja  cmp_ret_plus
    jmp cmp_ret_zero

cmp_ret_minus:
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    mov dx, 0FFFFh
    mov ax, dx
    pop bp
    RETMACRO 8

cmp_ret_plus:
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    xor dx, dx
    mov ax, 1
    pop bp
    RETMACRO 8

cmp_ret_zero:
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    xor dx, dx
    mov ax, dx
    pop bp
    RETMACRO 8

S32ADD:
U32ADD:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    mov ax, [a_low]
    add ax, [b_low]
    mov dx, [a_high]
    adc dx, [b_high]
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    pop bp
    RETMACRO 8

S32SUB:
U32SUB:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    mov ax, [a_low]
    sub ax, [b_low]
    mov dx, [a_high]
    sbb dx, [b_high]
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    pop bp
    RETMACRO 8

S32NEG:
    push bp
    mov bp, sp
    %define val_high bp+RSIZE+4
    %define val_low  bp+RSIZE+2
    mov dx, [val_high]
    mov ax, [val_low]
    not dx
    not ax
    add ax, 1
    adc dx, 0
    %undef val_high
    %undef val_low
    pop bp
    RETMACRO 4

S32MUL:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    push si
    push di
    sub sp, 6

    mov dx, [a_high]
    mov ax, [a_low]
    mov cx, [b_high]
    mov bx, [b_low]

    xor si, si
    test dx, 0x8000
    jz .chk_y
    mov si, 1
    not dx
    not ax
    add ax, 1
    adc dx, 0
.chk_y:
    test cx, 0x8000
    jz .save_abs
    xor si, 1
    not cx
    not bx
    add bx, 1
    adc cx, 0
.save_abs:
    mov [bp-8], bx
    mov [bp-10], cx
    mov [bp-6], si

    mov si, ax
    mov di, dx

    mov ax, si
    mul word [bp-8]
    mov bx, ax
    push dx

    mov ax, si
    mul word [bp-10]
    pop cx
    add cx, ax
    push cx

    mov ax, di
    mul word [bp-8]
    pop cx
    add cx, ax

    mov ax, bx
    mov dx, cx

    mov si, [bp-6]
    test si, 1
    jz .done
    not dx
    not ax
    add ax, 1
    adc dx, 0
.done:
    add sp, 6
    pop di
    pop si
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    pop bp
    RETMACRO 8

U32MUL:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    push si
    push di

    mov dx, [a_high]
    mov ax, [a_low]
    mov cx, [b_high]
    mov bx, [b_low]

    mov si, ax
    mov di, dx

    mov ax, si
    mul bx
    mov bx, ax
    push dx

    mov ax, si
    mul cx
    pop dx
    add dx, ax
    push dx

    mov ax, di
    mul word [b_low]
    pop cx
    add cx, ax

    mov ax, bx
    mov dx, cx

    pop di
    pop si
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    pop bp
    RETMACRO 8

S32DIV:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    push bx
    push cx
    push si
    push di
    mov dx, [a_high]
    mov ax, [a_low]
    mov cx, [b_high]
    mov bx, [b_low]
    xor si, si
    test dx, dx
    jns .check_b
    not dx
    not ax
    add ax, 1
    adc dx, 0
    not si
.check_b:
    test cx, cx
    jns .do_div
    not cx
    not bx
    add bx, 1
    adc cx, 0
    not si
.do_div:
    call div_kernel_32
    test si, si
    jz .end
    not dx
    not ax
    add ax, 1
    adc dx, 0
.end:
    pop di
    pop si
    pop cx
    pop bx
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    pop bp
    RETMACRO 8

S32MOD:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    push bx
    push cx
    push si
    push di
    mov dx, [a_high]
    mov ax, [a_low]
    mov cx, [b_high]
    mov bx, [b_low]
    xor si, si
    test dx, dx
    jns .check_b
    mov si, 1
    not dx
    not ax
    add ax, 1
    adc dx, 0
.check_b:
    test cx, cx
    jns .do_div
    not cx
    not bx
    add bx, 1
    adc cx, 0
.do_div:
    call div_kernel_32
    mov dx, cx
    mov ax, bx
    test si, si
    jz .end
    not dx
    not ax
    add ax, 1
    adc dx, 0
.end:
    pop di
    pop si
    pop cx
    pop bx
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    pop bp
    RETMACRO 8

U32DIV:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    push bx
    push si
    push di
    mov dx, [a_high]
    mov ax, [a_low]
    mov cx, [b_high]
    mov bx, [b_low]
    call div_kernel_32
    pop di
    pop si
    pop bx
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    pop bp
    RETMACRO 8

U32MOD:
    push bp
    mov bp, sp
    %define a_high bp+RSIZE+8
    %define a_low  bp+RSIZE+6
    %define b_high bp+RSIZE+4
    %define b_low  bp+RSIZE+2
    push bx
    push si
    push di
    mov dx, [a_high]
    mov ax, [a_low]
    mov cx, [b_high]
    mov bx, [b_low]
    call div_kernel_32
    mov dx, cx
    mov ax, bx
    pop di
    pop si
    pop bx
    %undef a_high
    %undef a_low
    %undef b_high
    %undef b_low
    pop bp
    RETMACRO 8

S32SHL:
U32SHL:
    push bp
    mov bp, sp
    %define val_high bp+RSIZE+6
    %define val_low  bp+RSIZE+4
    %define cnt      bp+RSIZE+2
    mov dx, [val_high]
    mov ax, [val_low]
    mov cx, [cnt]
    and cx, 0x3F
    cmp cx, 32
    jae .zero
    cmp cx, 0
    je .done
.loop:
    shl ax, 1
    rcl dx, 1
    dec cx
    jnz .loop
    jmp .done
.zero:
    xor ax, ax
    xor dx, dx
.done:
    %undef val_high
    %undef val_low
    %undef cnt
    pop bp
    RETMACRO 6

U32SHR:
    push bp
    mov bp, sp
    %define val_high bp+RSIZE+6
    %define val_low  bp+RSIZE+4
    %define cnt      bp+RSIZE+2
    mov dx, [val_high]
    mov ax, [val_low]
    mov cx, [cnt]
    and cx, 0x3F
    cmp cx, 32
    jae .zero
    cmp cx, 0
    je .done
.loop:
    shr dx, 1
    rcr ax, 1
    dec cx
    jnz .loop
    jmp .done
.zero:
    xor ax, ax
    xor dx, dx
.done:
    %undef val_high
    %undef val_low
    %undef cnt
    pop bp
    RETMACRO 6

S32SHR:
    push bp
    mov bp, sp
    %define val_high bp+RSIZE+6
    %define val_low  bp+RSIZE+4
    %define cnt      bp+RSIZE+2
    mov dx, [val_high]
    mov ax, [val_low]
    mov cx, [cnt]
    and cx, 0x3F
    cmp cx, 32
    jae .fill_sign
    cmp cx, 0
    je .done
.loop:
    sar dx, 1
    rcr ax, 1
    dec cx
    jnz .loop
    jmp .done
.fill_sign:
    cmp word [val_high], 0
    jns .pos_zero
    mov dx, 0FFFFh
    mov ax, dx
    jmp .done
.pos_zero:
    xor dx, dx
    xor ax, ax
.done:
    %undef val_high
    %undef val_low
    %undef cnt
    pop bp
    RETMACRO 6




