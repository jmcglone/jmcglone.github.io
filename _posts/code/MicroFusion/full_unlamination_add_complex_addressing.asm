mov     rax, rdi
shl     rax, 2
sub     rsp, rax

.loop:
add     DWORD [rsp + rdi * 4 - 4], 1
dec	rdi
jnz .loop

add     rsp, rax
ret
