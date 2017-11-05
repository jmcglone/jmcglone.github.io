#include <benchmark/benchmark.h>

unsigned char a[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
unsigned char b[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};

void add_arrays_scalar(unsigned char* a, unsigned char* b, unsigned n);
void add_arrays_vectorization_width_4(unsigned char* a, unsigned char* b, unsigned n);
void add_arrays_vectorization_width_8(unsigned char* a, unsigned char* b, unsigned n);
void add_arrays_vectorization_width_16(unsigned char* a, unsigned char* b, unsigned n);
void add_arrays_multiver_by_trip_counts(unsigned char* a, unsigned char* b, unsigned n);

static void Scalar(benchmark::State& state) 
{
  size_t total = 0;
  for (auto _ : state)
  {
      add_arrays_scalar(a, b, 4);
      add_arrays_scalar(a, b, 8);
      add_arrays_scalar(a, b, 16);
      total += 28;
  }
  state.SetBytesProcessed(total);
}
BENCHMARK(Scalar);

static void Vectorization_width_4(benchmark::State& state) 
{
  size_t total = 0;
  for (auto _ : state)
  {
      add_arrays_vectorization_width_4(a, b, 4);
      add_arrays_vectorization_width_4(a, b, 8);
      add_arrays_vectorization_width_4(a, b, 16);
      total += 28;
  }
  state.SetBytesProcessed(total);
}
BENCHMARK(Vectorization_width_4);

static void Vectorization_width_8(benchmark::State& state) 
{
  size_t total = 0;
  for (auto _ : state)
  {
      add_arrays_vectorization_width_8(a, b, 4);
      add_arrays_vectorization_width_8(a, b, 8);
      add_arrays_vectorization_width_8(a, b, 16);
      total += 28;
  }
  state.SetBytesProcessed(total);
}
BENCHMARK(Vectorization_width_8);

static void Vectorization_width_16(benchmark::State& state) 
{
  size_t total = 0;
  for (auto _ : state)
  {
      add_arrays_vectorization_width_16(a, b, 4);
      add_arrays_vectorization_width_16(a, b, 8);
      add_arrays_vectorization_width_16(a, b, 16);
      total += 28;
  }
  state.SetBytesProcessed(total);
}
BENCHMARK(Vectorization_width_16);

static void Multiver_by_trip_counts(benchmark::State& state) 
{
  size_t total = 0;
  for (auto _ : state)
  {
      add_arrays_multiver_by_trip_counts(a, b, 4);
      add_arrays_multiver_by_trip_counts(a, b, 8);
      add_arrays_multiver_by_trip_counts(a, b, 16);
      total += 28;
  }
  state.SetBytesProcessed(total);
}
BENCHMARK(Multiver_by_trip_counts);

BENCHMARK_MAIN();
