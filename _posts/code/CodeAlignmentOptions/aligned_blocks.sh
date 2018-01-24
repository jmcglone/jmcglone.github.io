#!/bin/sh
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-blocks=5
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A150 > aligned_blocks_5.txt
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-blocks=6
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A200 > aligned_blocks_6.txt
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-blocks=7
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A200 > aligned_blocks_7.txt
