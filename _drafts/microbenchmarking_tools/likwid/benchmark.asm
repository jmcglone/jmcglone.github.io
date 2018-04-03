;nasm -f elf64 test.asm

%define nop8 db 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00

GLOBAL benchmark

benchmark:
push rbx
push rcx

.loop:
mov eax, DWORD [rsi] 
mov eax, DWORD [rsi + 4]
bswap ebx
bswap ecx
dec rdi
jnz .loop

mov eax, 0

pop rcx
pop rbx

ret
ud2
