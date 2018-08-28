; nasm -f elf64 skid.asm
; gcc skid.o

%define nop8 db 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00
%macro cache_line 0
nop8 
nop8 
nop8 
nop8 
nop8 
nop8 
nop8 
nop8
%endmacro

GLOBAL main

main:
xor rax,rax
push rax
push rdi
; set number of iterations
mov rdi, 100000000

; allocate space on the stack
sub rsp, 4

.loop:

cache_line
cache_line
cache_line
cache_line

dec rdi
jnz .loop

add rsp, 4
pop rdi
pop rax
ret
ud2

