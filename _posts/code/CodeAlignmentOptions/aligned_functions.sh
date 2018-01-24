#!/bin/sh
#echo "-align-all-functions=5"
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-functions=5
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A30 > aligned_functions_5.txt
#echo "-align-all-functions=6"
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-functions=6
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A30 > aligned_functions_6.txt
#echo "-align-all-functions=7"
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp -mllvm -align-all-functions=7
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A30 > aligned_functions_7.txt
