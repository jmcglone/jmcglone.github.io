define_bench PortContention
push rcx
push rbx
ALIGN 16
.loop:
mov eax, DWORD [esi] 
mov eax, DWORD [esi + 4]
bswap ebx
bswap ecx
dec edi
jnz .loop
pop rbx
pop rcx
ret
