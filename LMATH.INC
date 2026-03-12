bits 16
cpu 8086

%ifdef TURBO
section CODE class=code
%else
section .text
%endif

%ifdef IS_FAR
RSIZE equ 4
%define RETMACRO retf
%else
RSIZE equ 2
%define RETMACRO retn
%endif

