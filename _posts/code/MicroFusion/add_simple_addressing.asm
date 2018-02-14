mov     rax, rdi
shl     rax, 2
sub     rsp, rax

add     DWORD [rsp], 1
add     DWORD [rsp + 4], 1
add     DWORD [rsp + 8], 1
add     DWORD [rsp + 12], 1
add     DWORD [rsp + 16], 1
add     DWORD [rsp + 20], 1
add     DWORD [rsp + 24], 1
add     DWORD [rsp + 28], 1
add     DWORD [rsp + 32], 1
add     DWORD [rsp + 36], 1

add     DWORD [rsp + 40], 1
add     DWORD [rsp + 44], 1
add     DWORD [rsp + 48], 1
add     DWORD [rsp + 52], 1
add     DWORD [rsp + 56], 1
add     DWORD [rsp + 60], 1
add     DWORD [rsp + 64], 1
add     DWORD [rsp + 68], 1
add     DWORD [rsp + 72], 1
add     DWORD [rsp + 76], 1

add     DWORD [rsp + 80], 1
add     DWORD [rsp + 84], 1
add     DWORD [rsp + 88], 1
add     DWORD [rsp + 92], 1
add     DWORD [rsp + 96], 1
add     DWORD [rsp + 100], 1
add     DWORD [rsp + 104], 1
add     DWORD [rsp + 108], 1
add     DWORD [rsp + 112], 1
add     DWORD [rsp + 116], 1

add     DWORD [rsp + 120], 1
add     DWORD [rsp + 124], 1
add     DWORD [rsp + 128], 1
add     DWORD [rsp + 132], 1
add     DWORD [rsp + 136], 1
add     DWORD [rsp + 140], 1
add     DWORD [rsp + 144], 1
add     DWORD [rsp + 148], 1
add     DWORD [rsp + 152], 1
add     DWORD [rsp + 156], 1

add     DWORD [rsp + 160], 1
add     DWORD [rsp + 164], 1
add     DWORD [rsp + 168], 1
add     DWORD [rsp + 172], 1
add     DWORD [rsp + 176], 1
add     DWORD [rsp + 180], 1
add     DWORD [rsp + 184], 1
add     DWORD [rsp + 188], 1
add     DWORD [rsp + 192], 1
add     DWORD [rsp + 196], 1

add     rsp, rax
ret
