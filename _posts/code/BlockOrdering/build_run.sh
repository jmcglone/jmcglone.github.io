../nasm/nasm -f elf64 foo_jmp.asm
../nasm/nasm -f elf64 foo_fall_through.asm
gcc a.cpp -O2 -c
gcc a.o foo_jmp.o -o a_jmp
gcc a.o foo_fall_through.o -o a_fall
echo "bad: jump to the hot path"
#time -p ./a_jmp
perf stat -e r53019c,instructions,cycles,L1-icache-load-misses -- ./a_jmp
echo "good: hot path fall through"
#time -p ./a_fall
perf stat -e r53019c,instructions,cycles,L1-icache-load-misses -- ./a_fall
#objdump -d -M intel a_jmp | grep "foo>:" -A 200 | grep hot -A 10 -B 5
#objdump -d -M intel a_fall | grep "foo>:" -A 200 | grep hot -A 10 -B 5


