const unsigned x = 0xF;
const unsigned y = 0x7;
//const float x = 0.1f;
//const float y = 0.2f;

#include <cmath>
#include <iostream>

int bench(volatile float X, volatile float Y);

int main()
{
  const float* X = (float*)&x;
  const float* Y = (float*)&y;

  std::cout << "x isnormal: " << std::isnormal(*X) << std::endl;
  std::cout << "y isnormal: " << std::isnormal(*Y) << std::endl;

  return bench(*X, *Y);
}
