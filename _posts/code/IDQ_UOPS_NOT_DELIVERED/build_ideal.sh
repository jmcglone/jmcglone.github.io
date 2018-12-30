../nasm/nasm -f elf64 ideal.s
gcc ideal.o 
objdump -d -M intel | grep "main.loop>:" -A 10
#time -p ./a.out
perf stat -e instructions,cycles,cpu/event=0x9c,umask=0x1,name=IDQ_UOPS_NOT_DELIVERED.CORE/ -- ./a.out

perf stat -e cycles,cpu/event=0x9c,umask=0x1,cmask=0x4,name=IDQ_UOPS_NOT_DELIVERED.CYCLES_0_UOP_DELIV.CORE/,cpu/event=0x9c,umask=0x1,cmask=0x3,name=IDQ_UOPS_NOT_DELIVERED.CYCLES_LE_1_UOP_DELIV.CORE/,cpu/event=0x9c,umask=0x1,cmask=0x2,name=IDQ_UOPS_NOT_DELIVERED.CYCLES_LE_2_UOP_DELIV.CORE/,cpu/event=0x9c,umask=0x1,cmask=0x1,name=IDQ_UOPS_NOT_DELIVERED.CYCLES_LE_3_UOP_DELIV.CORE/ -- ./a.out

perf stat -e cycles,cpu/event=0xA8,umask=0x01,cmask=0x1,name=LSD.CYCLES_ACTIVE/,cpu/event=0xA8,umask=0x01,cmask=0x4,name=LSD.CYCLES_4_UOPS/ -- ./a.out
