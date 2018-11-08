#include <cmath>
#include <iostream>
#include <cstring>

int bench(volatile float X, volatile float Y);

int main(int argc, char** argv)
{
  unsigned ux = 0xF;
  unsigned uy = 0x7;
  float fx = 0.1f;
  float fy = 0.2f;

  float* X;
  float* Y;

  if (!strcmp(argv[1], "denorm"))
  {
    X = (float*)&ux;
    Y = (float*)&uy;
  }
  else if (!strcmp(argv[1], "norm"))
  {
    X = &fx;
    Y = &fy;
  }
  else
  {
    std::cout << "_Aborted." << std::endl;
    return 1;
  }

  std::cout << "x isnormal: " << std::isnormal(*X) << std::endl;
  std::cout << "y isnormal: " << std::isnormal(*Y) << std::endl;

  return bench(*X, *Y);
}
