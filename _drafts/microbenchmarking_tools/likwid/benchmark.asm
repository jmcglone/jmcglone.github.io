;nasm -f elf64 test.asm

%define nop8 db 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00

GLOBAL benchmark

benchmark:

.loop:
mov eax, 1
dec rdi
jnz .loop

ret
ud2
