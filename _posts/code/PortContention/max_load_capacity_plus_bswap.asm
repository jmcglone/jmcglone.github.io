; nasm -f elf64 max_load_capacity_plus_bswap.asm
; gcc max_load_capacity_plus_bswap.o

GLOBAL main

main:
xor rax,rax
push rax
push rbx
push rdi
; set number of iterations
mov rdi, 1000

; allocate array on the stack
sub rsp, 64

	; uncomment for running under IACA
	; mov ebx, 111 ; Start marker bytes
	; db 0x64, 0x67, 0x90 ; Start marker bytes

.loop:
mov eax, DWORD [rsp]
mov eax, DWORD [rsp + 4]
bswap ebx
mov eax, DWORD [rsp + 8]
mov eax, DWORD [rsp + 12]
bswap ebx
mov eax, DWORD [rsp + 16]
mov eax, DWORD [rsp + 20]
bswap ebx
mov eax, DWORD [rsp + 24]
mov eax, DWORD [rsp + 28]
bswap ebx
mov eax, DWORD [rsp + 32]
mov eax, DWORD [rsp + 36]
bswap ebx
mov eax, DWORD [rsp + 40]
mov eax, DWORD [rsp + 44]
bswap ebx
mov eax, DWORD [rsp + 48]
mov eax, DWORD [rsp + 52]
bswap ebx
mov eax, DWORD [rsp + 56]
mov eax, DWORD [rsp + 60]
bswap ebx
dec rdi
jnz .loop

	; uncomment for running under IACA
	; mov ebx, 222 ; End marker bytes
	; db 0x64, 0x67, 0x90 ; End marker bytes

add rsp, 64
pop rdi
pop rbx
pop rax
ret
ud2
