mov     rax, rdi
shl     rax, 2
sub     rsp, rax
push	rcx
mov	rcx, 0

add     DWORD [rsp + rcx + 0], 1
add     DWORD [rsp + rcx + 4], 1
add     DWORD [rsp + rcx + 8], 1
add     DWORD [rsp + rcx + 12], 1
add     DWORD [rsp + rcx + 16], 1
add     DWORD [rsp + rcx + 20], 1
add     DWORD [rsp + rcx + 24], 1
add     DWORD [rsp + rcx + 28], 1
add     DWORD [rsp + rcx + 32], 1
add     DWORD [rsp + rcx + 36], 1

add     DWORD [rsp + rcx + 40], 1
add     DWORD [rsp + rcx + 44], 1
add     DWORD [rsp + rcx + 48], 1
add     DWORD [rsp + rcx + 52], 1
add     DWORD [rsp + rcx + 56], 1
add     DWORD [rsp + rcx + 60], 1
add     DWORD [rsp + rcx + 64], 1
add     DWORD [rsp + rcx + 68], 1
add     DWORD [rsp + rcx + 72], 1
add     DWORD [rsp + rcx + 76], 1

add     DWORD [rsp + rcx + 80], 1
add     DWORD [rsp + rcx + 84], 1
add     DWORD [rsp + rcx + 88], 1
add     DWORD [rsp + rcx + 92], 1
add     DWORD [rsp + rcx + 96], 1
add     DWORD [rsp + rcx + 100], 1
add     DWORD [rsp + rcx + 104], 1
add     DWORD [rsp + rcx + 108], 1
add     DWORD [rsp + rcx + 112], 1
add     DWORD [rsp + rcx + 116], 1

add     DWORD [rsp + rcx + 120], 1
add     DWORD [rsp + rcx + 124], 1
add     DWORD [rsp + rcx + 128], 1
add     DWORD [rsp + rcx + 132], 1
add     DWORD [rsp + rcx + 136], 1
add     DWORD [rsp + rcx + 140], 1
add     DWORD [rsp + rcx + 144], 1
add     DWORD [rsp + rcx + 148], 1
add     DWORD [rsp + rcx + 152], 1
add     DWORD [rsp + rcx + 156], 1

add     DWORD [rsp + rcx + 160], 1
add     DWORD [rsp + rcx + 164], 1
add     DWORD [rsp + rcx + 168], 1
add     DWORD [rsp + rcx + 172], 1
add     DWORD [rsp + rcx + 176], 1
add     DWORD [rsp + rcx + 180], 1
add     DWORD [rsp + rcx + 184], 1
add     DWORD [rsp + rcx + 188], 1
add     DWORD [rsp + rcx + 192], 1
add     DWORD [rsp + rcx + 196], 1

pop	rcx
add     rsp, rax
ret
