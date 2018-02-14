mov     rax, rdi
shl     rax, 2
sub     rsp, rax
push	rcx
mov	rcx, rsp

.loop:
add     DWORD [rcx], 1
add	rcx, 4
dec	rdi
jnz .loop

pop 	rcx
add     rsp, rax
ret
