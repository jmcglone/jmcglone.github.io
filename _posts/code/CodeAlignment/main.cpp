#include "benchmark/benchmark.h"
#include <random>

int a[32]; 

void benchmark_func(int* a);

static void func_bench(benchmark::State& state) 
{
  size_t total = 0;
  for (auto _ : state)
  {
      benchmark_func(a);
      total += 32 * 4;
  }
  
  for (int i = 0; i < 32; ++i) 
    benchmark::DoNotOptimize(a[i]);

  state.SetBytesProcessed(total);
}
BENCHMARK(func_bench);

int main(int argc, char *argv[]) 
{
  std::random_device rd;  
  std::mt19937 gen(rd()); 
  std::uniform_int_distribution<> dis(0, 31); 
  for (int i = 0; i < 32; ++i) 
  {
    a[i] = dis(gen);
  }

  ::benchmark::Initialize(&argc, argv);
  ::benchmark::RunSpecifiedBenchmarks();
}
