%define nop8 db 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00

GLOBAL main

main:
push rdx
push rsi
push rdi
push rcx
mov rax, 0
mov rdx, 1000000000

ALIGN 64

.loop:
inc rcx
inc rsi
inc rdi
;bswap edi
dec rdx
jnz .loop

xor rax, rax
pop rcx
pop rdi
pop rsi
pop rdx
ret
ud2
