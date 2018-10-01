template <class Tp>
inline void DoNotOptimize(Tp const& value) {
    asm volatile("" : : "r,m"(value) : "memory");
}

template <class Tp>
inline void DoNotOptimize(Tp& value) {
#if defined(__clang__)
    asm volatile("" : "+r,m"(value) : : "memory");
#else
      asm volatile("" : "+m,r"(value) : : "memory");
#endif
}

int bench(volatile float x, volatile float y)
{
  float sum = 0.0f;
  for (int i = 0; i < 1000000000; i++)
  {
    sum = x / y;
    DoNotOptimize(sum);
    sum = 0.0f;
  }
  return (int)sum;
}
