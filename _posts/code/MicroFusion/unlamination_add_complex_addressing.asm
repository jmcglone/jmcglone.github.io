mov     rax, rdi
shl     rax, 2
sub     rsp, rax
push	rbx

.loop:
add     ebx, DWORD [rsp + rdi * 4 - 4]
dec	rdi
jnz .loop

pop 	rbx
add     rsp, rax
ret
