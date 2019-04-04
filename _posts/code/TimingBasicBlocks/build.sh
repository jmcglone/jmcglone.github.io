~/nasm/nasm -f elf64 foo.asm
g++ a.cpp -O2 -c -std=c++11
g++ a.o foo.o
~/perf record -b -e cycles ./a.out
~/perf script -F +brstackinsn  | ../xed -F insn: -A -64 > dump.txt
