~/nasm/nasm -f elf64 foo.asm
g++ a.cpp -O2 -c -std=c++11
g++ a.o foo.o
perf stat -e cycles,instructions,cpu/event=0xa3,umask=0x6,cmask=0x6,name=CYCLE_ACTIVITY.STALLS_L3_MISS/,cpu/event=0xd1,umask=0x20,name=MEM_LOAD_RETIRED.L3_MISS/ ./a.out
