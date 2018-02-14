define_bench dendibakh_MicroFusion_inc
mov     rax, rdi
shl     rax, 2
sub     rsp, rax

inc     DWORD [rsp]
inc     DWORD [rsp + 4]
inc     DWORD [rsp + 8]
inc     DWORD [rsp + 12]
inc     DWORD [rsp + 16]
inc     DWORD [rsp + 20]
inc     DWORD [rsp + 24]
inc     DWORD [rsp + 28]
inc     DWORD [rsp + 32]
inc     DWORD [rsp + 36]

inc     DWORD [rsp + 40]
inc     DWORD [rsp + 44]
inc     DWORD [rsp + 48]
inc     DWORD [rsp + 52]
inc     DWORD [rsp + 56]
inc     DWORD [rsp + 60]
inc     DWORD [rsp + 64]
inc     DWORD [rsp + 68]
inc     DWORD [rsp + 72]
inc     DWORD [rsp + 76]

inc     DWORD [rsp + 80]
inc     DWORD [rsp + 84]
inc     DWORD [rsp + 88]
inc     DWORD [rsp + 92]
inc     DWORD [rsp + 96]
inc     DWORD [rsp + 100]
inc     DWORD [rsp + 104]
inc     DWORD [rsp + 108]
inc     DWORD [rsp + 112]
inc     DWORD [rsp + 116]

inc     DWORD [rsp + 120]
inc     DWORD [rsp + 124]
inc     DWORD [rsp + 128]
inc     DWORD [rsp + 132]
inc     DWORD [rsp + 136]
inc     DWORD [rsp + 140]
inc     DWORD [rsp + 144]
inc     DWORD [rsp + 148]
inc     DWORD [rsp + 152]
inc     DWORD [rsp + 156]

inc     DWORD [rsp + 160]
inc     DWORD [rsp + 164]
inc     DWORD [rsp + 168]
inc     DWORD [rsp + 172]
inc     DWORD [rsp + 176]
inc     DWORD [rsp + 180]
inc     DWORD [rsp + 184]
inc     DWORD [rsp + 188]
inc     DWORD [rsp + 192]
inc     DWORD [rsp + 196]

add     rsp, rax
ret

define_bench dendibakh_MicroFusion_add
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

define_bench dendibakh_MicroFusion_add_complex_addr
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

** Running benchmark group MicroFusion tests from dendibakh blog **
                     Benchmark   Cycles   IDQ:DS   UOPS_R   UOPS_R   LSD:UO
                     inc [esp]     1.12     0.06     3.08     4.08     0.00
                  add [esp], 1     1.10     0.06     2.08     4.08     0.00
            add [esp + ecx], 1     1.40     0.00     4.18     4.20     0.00



define_bench dendibakh_MicroFusion_add_complex_addr_unlamination
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

** Running benchmark group MicroFusion tests from dendibakh blog **
                     Benchmark   Cycles   IDQ:DS   UOPS_R   UOPS_R   LSD:UO
     add [esp + edx] - loop, 1     1.20     2.13     3.27     3.30     0.00

define_bench dendibakh_MicroFusion_add_complex_addr_unlamination_inc
mov     rax, rdi
shl     rax, 2
sub     rsp, rax
push	rcx
mov	rcx, rsp

.loop:
inc     DWORD [rcx]
add	rcx, 4
dec	rdi
jnz .loop

pop 	rcx
add     rsp, rax
ret

** Running benchmark group MicroFusion tests from dendibakh blog **
                     Benchmark   Cycles   IDQ:DS   UOPS_R   UOPS_R   LSD:UO
     inc [esp + edx] - loop, 1     1.57     5.03     5.30     6.33     0.00

it was not unlaminated



define_bench dendibakh_MicroFusion_add_complex_addr_unlamination_inc
mov     rax, rdi
shl     rax, 2
sub     rsp, rax

.loop:
add     DWORD [rsp + rdi * 4 - 4], 1
dec	rdi
jnz .loop

add     rsp, rax
ret

** Running benchmark group MicroFusion tests from dendibakh blog **
                     Benchmark   Cycles   IDQ:DS   UOPS_R   UOPS_R   LSD:UO
     inc [esp + edx] - loop, 1     1.47     3.07     5.13     5.13     0.00



define_bench dendibakh_MicroFusion_add_complex_addr_unlamination_inc
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


** Running benchmark group MicroFusion tests from dendibakh blog **
                     Benchmark   Cycles   IDQ:DS   UOPS_R   UOPS_R   LSD:UO
     inc [esp + edx] - loop, 1     1.47     4.07     4.30     6.33     0.00



