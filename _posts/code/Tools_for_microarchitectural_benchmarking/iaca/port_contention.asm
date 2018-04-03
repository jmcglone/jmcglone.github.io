; nasm -f elf64 port_contention.asm
; gcc port_contention.o 
; ./iaca -arch HSW -trace iaca.log -trace-cycle-count 50 ./a.out

GLOBAL main

main:
xor rax,rax
push rax
push rbx
push rcx
push rdi
; set number of iterations
mov rdi, 1000

; allocate array on the stack
sub rsp, 8

	mov ebx, 111 		; Start marker bytes
	db 0x64, 0x67, 0x90 	; Start marker bytes

.loop:
mov eax, DWORD [rsp] 
mov eax, DWORD [rsp + 4]
bswap ebx
bswap ecx
dec rdi
jnz .loop

	mov ebx, 222 		; End marker bytes
	db 0x64, 0x67, 0x90 	; End marker bytes

add rsp, 64
pop rdi
pop rcx
pop rbx
pop rax
ret
ud2
