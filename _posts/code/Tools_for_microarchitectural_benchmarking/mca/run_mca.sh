$ cat a.asm
movl (%esp), %eax
movl 4(%esp), %eax
bswapl %ebx
bswapl %ecx
$ llvm-mca -march=x86-64 -mcpu=ivybridge -output-asm-variant=1 -timeline ./a.asm -o mca.out
