#include "benchmark/benchmark.h"
#include <random>
#include <fstream>
#include <iostream>

unsigned char a[32]; // random numbers from 0 to 31
unsigned char b[32]; // random numbers from 0 to 31

unsigned tripCount4; // = 4
unsigned tripCount8; // = 8
unsigned tripCount16;// = 16

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
      add_arrays_scalar(a, b, tripCount4);
      add_arrays_scalar(a, b, tripCount8);
      add_arrays_scalar(a, b, tripCount16);
      for (int i = 0; i < 32; ++i) 
      {
       benchmark::DoNotOptimize(a[i]);
       benchmark::DoNotOptimize(b[i]);
      }
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
      add_arrays_vectorization_width_4(a, b, tripCount4);
      add_arrays_vectorization_width_4(a, b, tripCount8);
      add_arrays_vectorization_width_4(a, b, tripCount16);
      for (int i = 0; i < 32; ++i) 
      {
       benchmark::DoNotOptimize(a[i]);
       benchmark::DoNotOptimize(b[i]);
      }
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
      add_arrays_vectorization_width_8(a, b, tripCount4);
      add_arrays_vectorization_width_8(a, b, tripCount8);
      add_arrays_vectorization_width_8(a, b, tripCount16);
      for (int i = 0; i < 32; ++i) 
      {
       benchmark::DoNotOptimize(a[i]);
       benchmark::DoNotOptimize(b[i]);
      }
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
      add_arrays_vectorization_width_16(a, b, tripCount4);
      add_arrays_vectorization_width_16(a, b, tripCount8);
      add_arrays_vectorization_width_16(a, b, tripCount16);
      for (int i = 0; i < 32; ++i) 
      {
       benchmark::DoNotOptimize(a[i]);
       benchmark::DoNotOptimize(b[i]);
      }
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
      add_arrays_multiver_by_trip_counts(a, b, tripCount4);
      add_arrays_multiver_by_trip_counts(a, b, tripCount8);
      add_arrays_multiver_by_trip_counts(a, b, tripCount16);
      for (int i = 0; i < 32; ++i) 
      {
       benchmark::DoNotOptimize(a[i]);
       benchmark::DoNotOptimize(b[i]);
      }
      total += 28;
  }
  state.SetBytesProcessed(total);
}
BENCHMARK(Multiver_by_trip_counts);

int main(int argc, char *argv[]) 
{
  std::random_device rd;  
  std::mt19937 gen(rd()); 
  std::uniform_int_distribution<> dis(0, 31); 
  for (int i = 0; i < 32; ++i) 
  {
    a[i] = dis(gen);
    b[i] = dis(gen);
  }

  { 
    std::ifstream f;
    f.open("TC4.txt");
    f >> tripCount4;
    f.close();
  }
  { 
    std::ifstream f;
    f.open("TC8.txt");
    f >> tripCount8;
    f.close();
  }
  { 
    std::ifstream f;
    f.open("TC16.txt");
    f >> tripCount16;
    f.close();
  }

  ::benchmark::Initialize(&argc, argv);
  ::benchmark::RunSpecifiedBenchmarks();
}
