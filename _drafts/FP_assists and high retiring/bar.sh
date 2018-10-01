g++ a.cpp -O1 -march=core-avx2 -c
g++ b.cpp -O1 -march=core-avx2 -c
g++ a.o b.o
objdump -d ./a.out -M intel | grep "benchff>:" -A 20
time -p ./a.out

