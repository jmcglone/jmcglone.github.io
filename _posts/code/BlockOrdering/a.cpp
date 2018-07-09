extern "C" { void foo(int, int); }

int main()
{
  for (int i = 0; i < 1000000000; i++)
    foo(0, 32);
  return 0;
}
