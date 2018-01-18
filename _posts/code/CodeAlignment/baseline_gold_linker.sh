clang++ -c -o func.o -std=c++11 -O2 -march=skylake -fno-unroll-loops func.cpp 
clang++ -c -o main.o -std=c++11 -O2 -march=skylake -fno-unroll-loops main.cpp 
clang++ -fuse-ld=gold -O2 -march=skylake -fno-unroll-loops main.o func.o -L. -lbenchmark -lpthread
./a.out
objdump -d a.out -M intel | grep "call.*<_Z14benchmark_funcPi>" -A2 -B1
objdump -d a.out -M intel | grep "<_Z14benchmark_funcPi>:" -A15
