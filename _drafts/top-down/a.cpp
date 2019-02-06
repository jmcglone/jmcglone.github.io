#include <random>

extern "C" { void foo(char* a, int n); }

const int _20MB = 1024*1024*50;

int main() {
  char* a = (char*)malloc(_20MB); // 20 MB buffer
  for (int i = 0; i < _20MB; i++) {
    a[i] = 0;
  }

  const int min = 1;
  const int max = _20MB;
  std::default_random_engine generator;
  std::uniform_int_distribution<int> distribution(min,max);

  for (int i = 0; i < 100000000; i++) {
    int random_int = distribution(generator);
    foo(a, random_int);
  }

  free(a);
  return 0;
}
