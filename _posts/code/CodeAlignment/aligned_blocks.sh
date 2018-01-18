clang++ -c -o func.o -std=c++11 -O2 -march=skylake -fno-unroll-loops func_no_foo.cpp -mllvm -align-all-blocks=5
clang++ -c -o main.o -std=c++11 -O2 -march=skylake -fno-unroll-loops main.cpp
clang++ -O2 -march=skylake -fno-unroll-loops main.o func.o -L. -lbenchmark -lpthread
./a.out --benchmark_repetitions=5 --benchmark_report_aggregates_only=true
objdump -d a.out -M intel | grep "call.*<_Z14benchmark_funcPi>" -A2 -B1
objdump -d a.out -M intel | grep "<_Z14benchmark_funcPi>:" -A20
