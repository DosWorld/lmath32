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
;
; ==============================================================================
; STRING CONVERSION
; ==============================================================================

; ------------------------------------------------------------------------------
; S32TOA (Signed)
; ------------------------------------------------------------------------------
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

    ; Load Buffer Pointer to ES:DI
    mov ax, [bp+8]      ; Segment
    mov es, ax
    mov di, [bp+6]      ; Offset

    ; Load Value to DX:AX
    mov dx, [bp+12]
    mov ax, [bp+10]

    ; Check Sign
    test dx, dx
    jns .is_positive

    ; Handle negative: write '-' and negate
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

; ------------------------------------------------------------------------------
; U32TOA (Unsigned)
; ------------------------------------------------------------------------------
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

    mov ax, [bp+8]      ; Segment
    mov es, ax
    mov di, [bp+6]      ; Offset

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

; ------------------------------------------------------------------------------
; INTERNAL: u32toa_internal (Near Call)
; BUG FIX: CX is now preserved across local_div_10 call
; ------------------------------------------------------------------------------
u32toa_internal:
    ; Check if value is 0
    mov bx, dx
    or bx, ax
    jnz .convert
    
    mov byte [es:di], '0'
    inc di
    mov byte [es:di], 0
    ret

.convert:
    xor cx, cx          ; Digit counter

.loop_div:
    push cx             ; <--- FIX: Save digit counter
    call local_div_10   ; DX:AX = Quot, BX = Remainder. Destroys CX!
    pop cx              ; <--- FIX: Restore digit counter
    
    add bl, '0'
    push bx             ; Push char to stack
    inc cx              ; Increment digit count
    
    ; Check if Quotient (DX:AX) is 0
    mov si, dx
    or si, ax
    jnz .loop_div

.write_loop:
    pop ax
    stosb               ; Write char from stack to buffer
    loop .write_loop

    mov byte [es:di], 0 ; Null terminator
    ret

; ------------------------------------------------------------------------------
; INTERNAL: local_div_10 (Near Call)
; Divide DX:AX by 10. Result in DX:AX, Remainder in BX.
; Destroys: CX
; ------------------------------------------------------------------------------
local_div_10:
    mov cx, 10
    push ax
    mov ax, dx
    xor dx, dx
    div cx          ; Divide High Word
    mov bx, ax      ; BX = High Quotient
    pop ax
    div cx          ; Divide (Rem_High:Low)
    
    ; Now: AX = Low Quotient, DX = Final Remainder
    mov cx, dx      ; Save Remainder temporarily
    mov dx, bx      ; DX = High Quotient
    mov bx, cx      ; BX = Final Remainder
    ret

; ==============================================================================
; KERNEL (Near Call)
; ==============================================================================
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

; ==============================================================================
; COMPARISON (FAR CALLS)
; FIX: Shared labels are now named globally (no dots) to avoid scope issues
; ==============================================================================
S32CMP:
    push bp
    mov bp, sp
    mov dx, [bp+12]
    cmp dx, [bp+8]
    jl cmp_ret_minus
    jg cmp_ret_plus
    mov ax, [bp+10]
    cmp ax, [bp+6]
    jb cmp_ret_minus
    ja cmp_ret_plus
    jmp cmp_ret_zero

U32CMP:
    push bp
    mov bp, sp
    mov dx, [bp+12]
    cmp dx, [bp+8]
    jb cmp_ret_minus
    ja cmp_ret_plus
    mov ax, [bp+10]
    cmp ax, [bp+6]
    jb cmp_ret_minus
    ja cmp_ret_plus
    jmp cmp_ret_zero

; -- Global Shared Exit Points --
cmp_ret_minus:
    mov dx, 0FFFFh
    mov ax, 0FFFFh
    pop bp
    retf 8

cmp_ret_plus:
    xor dx, dx
    mov ax, 1
    pop bp
    retf 8

cmp_ret_zero:
    xor dx, dx
    xor ax, ax
    pop bp
    retf 8

; ==============================================================================
; ARITHMETIC (FAR CALLS)
; ==============================================================================
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

S32MUL:
    push bp
    mov bp, sp
    mov ax, [bp+10]
    imul word [bp+8]
    mov cx, ax
    mov ax, [bp+6]
    imul word [bp+12]
    add cx, ax
    mov ax, [bp+10]
    mul word [bp+6]
    add dx, cx
    pop bp
    retf 8

U32MUL:
    push bp
    mov bp, sp
    mov ax, [bp+10]
    mul word [bp+8]
    mov cx, ax
    mov ax, [bp+6]
    mul word [bp+12]
    add cx, ax
    mov ax, [bp+10]
    mul word [bp+6]
    add dx, cx
    pop bp
    retf 8

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
    not si
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

; ==============================================================================
; SHIFT OPERATIONS (FAR CALLS)
; ==============================================================================
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
    jcxz .done
.loop:
    shl ax, 1
    rcl dx, 1
    loop .loop
    jmp .done
.zero:
    xor ax, ax
    xor dx, dx
.done:
    pop bp
    retf 6

U32SHR:
    push bp
    mov bp, sp
    mov dx, [bp+10]
    mov ax, [bp+8]
    mov cx, [bp+6]
    and cx, 0x3F
    cmp cx, 32
    jae .zero
    jcxz .done
.loop:
    shr dx, 1
    rcr ax, 1
    loop .loop
    jmp .done
.zero:
    xor ax, ax
    xor dx, dx
.done:
    pop bp
    retf 6

S32SHR:
    push bp
    mov bp, sp
    mov dx, [bp+10]
    mov ax, [bp+8]
    mov cx, [bp+6]
    and cx, 0x3F
    cmp cx, 32
    jae .fill_sign
    jcxz .done
.loop:
    sar dx, 1
    rcr ax, 1
    loop .loop
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


