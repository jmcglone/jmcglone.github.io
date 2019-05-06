#include <random>

struct A {
  virtual void foo(int N) = 0;
};

struct B : public A { 
  void foo(int N) override; 
};

struct C : public A { 
  void foo(int N) override; 
};

struct D : public A { 
  void foo(int N) override; 
};

int main() {
  const int min = 0;
  const int max = 9;
  std::default_random_engine generator;
  std::uniform_int_distribution<int> distribution(min,max);

  B b;
  C c;
  D d;
  A* a = nullptr;
  for (int i = 0; i < 100000000; i++) {
    int random_int = distribution(generator);
    if (random_int == 0)
      a = &b; // 10%
    else if (random_int < 4)
      a = &c; // 30%
    else 
      a = &d; // 60%
    a->foo(random_int);
  }

  return 0;
}
