#!/bin/sh
#echo "no-options"
clang++ -c -o func.o -O2 -march=skylake -fno-unroll-loops func.cpp
objdump -d func.o -M intel | grep "<_Z4funcPi>:" -A30 > no_options.txt
