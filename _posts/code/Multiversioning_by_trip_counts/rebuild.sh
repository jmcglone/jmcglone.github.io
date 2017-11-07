clang++ -c -o mvtr.o -O3 -march=core-avx2 mvtr.cpp
clang++ -c -o mvtr_main.o -std=c++11 -O3 -march=core-avx2 mvtr_main.cpp
clang++ -O3 -march=core-avx2 mvtr.o mvtr_main.o -lbenchmark -lpthread
