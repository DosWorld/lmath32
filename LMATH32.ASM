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

; S32TOA (Signed)
; Converts signed 32-bit integer to ASCIIZ string
; Input: far pointer to buffer (segment:offset), 32-bit value in DX:AX
; Output: string at buffer, terminated by 0
S32TOA:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, [bp+8]
    mov es, ax
    mov di, [bp+6]

    mov dx, [bp+12]
    mov ax, [bp+10]

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
    pop bp
    retf 8

; U32TOA (Unsigned)
; Converts unsigned 32-bit integer to ASCIIZ string
; Input: far pointer to buffer (segment:offset), 32-bit value in DX:AX
; Output: string at buffer, terminated by 0
U32TOA:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, [bp+8]
    mov es, ax
    mov di, [bp+6]

    mov dx, [bp+12]
    mov ax, [bp+10]

    call u32toa_internal

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    retf 8

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

; S32CMP (Signed)
; Compares two signed 32-bit integers
; Input: two 32-bit values on stack (first: DX:AX, second: high word, low word)
; Output: DX:AX = -1 if first < second, 0 if equal, 1 if first > second
S32CMP:
    push bp
    mov bp, sp
    mov dx, [bp+12]
    cmp dx, [bp+8]
    jl  cmp_ret_minus
    jg  cmp_ret_plus
    mov ax, [bp+10]
    cmp ax, [bp+6]
    jb  cmp_ret_minus
    ja  cmp_ret_plus
    jmp cmp_ret_zero

; U32CMP (Unsigned)
; Compares two unsigned 32-bit integers
; Input: two 32-bit values on stack (first: DX:AX, second: high word, low word)
; Output: DX:AX = -1 if first < second, 0 if equal, 1 if first > second
U32CMP:
    push bp
    mov bp, sp
    mov dx, [bp+12]
    cmp dx, [bp+8]
    jb  cmp_ret_minus
    ja  cmp_ret_plus
    mov ax, [bp+10]
    cmp ax, [bp+6]
    jb  cmp_ret_minus
    ja  cmp_ret_plus
    jmp cmp_ret_zero

cmp_ret_minus:
    mov dx, 0FFFFh
    mov ax, dx
    pop bp
    retf 8

cmp_ret_plus:
    xor dx, dx
    mov ax, 1
    pop bp
    retf 8

cmp_ret_zero:
    xor dx, dx
    mov ax, dx
    pop bp
    retf 8

; S32ADD (Signed) and U32ADD (Unsigned)
; Adds two 32-bit integers
; Input: two 32-bit values on stack (first: DX:AX, second: high word, low word)
; Output: DX:AX = sum
S32ADD:
U32ADD:
    push bp
    mov bp, sp
    mov ax, [bp+10]
    add ax, [bp+6]
    mov dx, [bp+12]
    adc dx, [bp+8]
    pop bp
    retf 8

; S32SUB (Signed) and U32SUB (Unsigned)
; Subtracts two 32-bit integers
; Input: two 32-bit values on stack (first: DX:AX, second: high word, low word)
; Output: DX:AX = first - second
S32SUB:
U32SUB:
    push bp
    mov bp, sp
    mov ax, [bp+10]
    sub ax, [bp+6]
    mov dx, [bp+12]
    sbb dx, [bp+8]
    pop bp
    retf 8

; S32NEG (Signed)
; Negates a 32-bit integer
; Input: 32-bit value on stack (high word, low word)
; Output: DX:AX = -value
S32NEG:
    push bp
    mov bp, sp
    mov dx, [bp+8]
    mov ax, [bp+6]
    not dx
    not ax
    add ax, 1
    adc dx, 0
    pop bp
    retf 4

; S32MUL (Signed)
; Multiplies two signed 32-bit integers
; Input: two 32-bit values on stack (first: DX:AX, second: high word, low word)
; Output: DX:AX = product
S32MUL:
    push bp
    mov bp, sp
    push si
    push di
    sub sp, 6

    mov dx, [bp+12]
    mov ax, [bp+10]
    mov cx, [bp+8]
    mov bx, [bp+6]

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
    pop bp
    retf 8

; U32MUL (Unsigned)
; Multiplies two unsigned 32-bit integers
; Input: two 32-bit values on stack (first: DX:AX, second: high word, low word)
; Output: DX:AX = product
U32MUL:
    push bp
    mov bp, sp
    push si
    push di

    mov dx, [bp+12]
    mov ax, [bp+10]
    mov cx, [bp+8]
    mov bx, [bp+6]

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
    mul word [bp+6]
    pop cx
    add cx, ax

    mov ax, bx
    mov dx, cx

    pop di
    pop si
    pop bp
    retf 8

; S32DIV (Signed)
; Divides two signed 32-bit integers
; Input: two 32-bit values on stack (dividend: DX:AX, divisor: high word, low word)
; Output: DX:AX = quotient
S32DIV:
    push bp
    mov bp, sp
    push bx
    push cx
    push si
    push di
    mov dx, [bp+12]
    mov ax, [bp+10]
    mov cx, [bp+8]
    mov bx, [bp+6]
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
    pop bp
    retf 8

; S32MOD (Signed)
; Computes remainder of signed division
; Input: two 32-bit values on stack (dividend: DX:AX, divisor: high word, low word)
; Output: DX:AX = remainder (sign of dividend)
S32MOD:
    push bp
    mov bp, sp
    push bx
    push cx
    push si
    push di
    mov dx, [bp+12]
    mov ax, [bp+10]
    mov cx, [bp+8]
    mov bx, [bp+6]
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
    pop bp
    retf 8

; U32DIV (Unsigned)
; Divides two unsigned 32-bit integers
; Input: two 32-bit values on stack (dividend: DX:AX, divisor: high word, low word)
; Output: DX:AX = quotient
U32DIV:
    push bp
    mov bp, sp
    push bx
    push si
    push di
    mov dx, [bp+12]
    mov ax, [bp+10]
    mov cx, [bp+8]
    mov bx, [bp+6]
    call div_kernel_32
    pop di
    pop si
    pop bx
    pop bp
    retf 8

; U32MOD (Unsigned)
; Computes remainder of unsigned division
; Input: two 32-bit values on stack (dividend: DX:AX, divisor: high word, low word)
; Output: DX:AX = remainder
U32MOD:
    push bp
    mov bp, sp
    push bx
    push si
    push di
    mov dx, [bp+12]
    mov ax, [bp+10]
    mov cx, [bp+8]
    mov bx, [bp+6]
    call div_kernel_32
    mov dx, cx
    mov ax, bx
    pop di
    pop si
    pop bx
    pop bp
    retf 8

; S32SHL (Signed) and U32SHL (Unsigned)
; Shifts 32-bit value left
; Input: 32-bit value in DX:AX, shift count in CX (clipped to 0..63)
; Output: DX:AX = value << count
S32SHL:
U32SHL:
    push bp
    mov bp, sp
    mov dx, [bp+10]
    mov ax, [bp+8]
    mov cx, [bp+6]
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
    pop bp
    retf 6

; U32SHR (Unsigned)
; Shifts unsigned 32-bit value right (logical shift)
; Input: 32-bit value in DX:AX, shift count in CX (clipped to 0..63)
; Output: DX:AX = value >> count (zero fill)
U32SHR:
    push bp
    mov bp, sp
    mov dx, [bp+10]
    mov ax, [bp+8]
    mov cx, [bp+6]
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
    pop bp
    retf 6

; S32SHR (Signed)
; Shifts signed 32-bit value right (arithmetic shift)
; Input: 32-bit value in DX:AX, shift count in CX (clipped to 0..63)
; Output: DX:AX = value >> count (sign extended)
S32SHR:
    push bp
    mov bp, sp
    mov dx, [bp+10]
    mov ax, [bp+8]
    mov cx, [bp+6]
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
    cmp word [bp+10], 0
    jns .pos_zero
    mov dx, 0FFFFh
    mov ax, 0FFFFh
    jmp .done
.pos_zero:
    xor dx, dx
    xor ax, ax
.done:
    pop bp
    retf 6




