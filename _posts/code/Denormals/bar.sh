g++ a.cpp -O1 -march=core-avx2 -c
g++ b.cpp -O1 -march=core-avx2 -c
g++ a.o b.o
objdump -d ./a.out -M intel | grep "benchff>:" -A 20
#time -p ./a.out norm
#time -p ./a.out denorm
perf stat -e cycles,cpu/event=0xc2,umask=0x2,name=UOPS_RETIRED.RETIRE_SLOTS/,cpu/event=0xca,umask=0x1e,cmask=0x1,name=FP_ASSIST.ANY/,cpu/event=0x79,umask=0x30,name=IDQ.MS_UOPS/ ./a.out norm
perf stat -e cycles,cpu/event=0xc2,umask=0x2,name=UOPS_RETIRED.RETIRE_SLOTS/,cpu/event=0xca,umask=0x1e,cmask=0x1,name=FP_ASSIST.ANY/,cpu/event=0x79,umask=0x30,name=IDQ.MS_UOPS/ ./a.out denorm
