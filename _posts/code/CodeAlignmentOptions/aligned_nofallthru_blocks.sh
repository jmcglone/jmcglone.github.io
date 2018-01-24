#!/bin/sh
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-nofallthru-blocks=5
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A200 > align-all-nofallthru-blocks_5.txt
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-nofallthru-blocks=6
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A200 > align-all-nofallthru-blocks_6.txt
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-nofallthru-blocks=7
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A200 > align-all-nofallthru-blocks_7.txt
