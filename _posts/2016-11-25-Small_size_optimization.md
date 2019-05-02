---
layout: post
title: Small size optimization.
categories: [C++, optimizations]
---

As Chandler Carruth said in his [talk at CppCon 2016](https://www.youtube.com/watch?v=vElZc6zSIXM&list=PLHTh1InhhwT7J5jl4vAhO1WvGHUUFgUQH&index=35), a lot of people underestimate the benefit of [Small Size Optimization](https://www.google.pl/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwimkb-K-cTQAhVIDCwKHfx4CyIQFggdMAA&url=http%3A%2F%2Fnullprogram.com%2Fblog%2F2016%2F10%2F07%2F&usg=AFQjCNGWk5vqGN5Mf0Deu3XtDS98s8dAXA&sig2=ysMLY351GtM-Fw2pdShHAQ)(SSO).

I decided to give a simple implementation of this idea. The problem in using `std::vector` is that as the number of elements grows memory allocations become more and more expensive. Not only that we need to find the memory for more elements, but we need also to move(copy) our elements to new location. Usually there are `log(N)` memory allocations, depending on the implementation of course.

But let's think for a moment... With high probability I can say that most of the time the number of elements in our containers do not exceed 100. Maybe the number is even less.

Idea behind SSO is to allocate memory on the stack (which is just shifting the stack pointer against `malloc` syscall). And only if we exceed this preallocated buffer we will fallback to the heap storage. With this we essentially cover the majority of the scenarios.

Of course we should keep in mind that this optimization consumes more memory. However, we can adjust the amount preallocated memory. Keep on reading...

```cpp
template <unsigned N>
class SmallVector
{
  public:
    SmallVector();
    ~SmallVector();

    SmallVector(const SmallVector& rhs) = delete;
    SmallVector& operator=(const SmallVector& rhs) = delete;

    void push_back(int value);
    int& operator[](size_t index);
    int& at(size_t index);

  protected:
    std::array<int, N> smallBuffer;
    unsigned size;
    unsigned capacity;
    int* heapVector;
};
```

Usually the size of `std::vector` equals to the size of 3 pointers. In our case it looks pretty similar with additional plain `std::array` as this small buffer.

We initially point `heapVector` to the beginning of our `smallBuffer`.

```cpp
template <unsigned N>
SmallVector<N>::SmallVector() : size(0), capacity(N), heapVector(smallBuffer.data())
{
  for (auto& e : smallBuffer)
    e = int();
}
```

Implementation of `operator[]` is trivial:

```cpp
template <unsigned N>
int& SmallVector<N>::operator[](size_t index)
{
  return heapVector[index];
}

```

The most interesting part of the code is inside `push_back`:

```cpp
template <unsigned N>
void SmallVector<N>::push_back(int value)
{
  if (size == capacity)
  {
    int* newStorage = new int[capacity * 2];
    capacity *= 2;
    memcpy(newStorage, heapVector, size * sizeof(int));
    if (heapVector != smallBuffer.data())
      delete [] heapVector;
    heapVector = newStorage;
  }
  heapVector[size++] = value;
}
```

So, as long as we do not exceed our storage allocated on the stack we will not even go into the heap. This can give us a huge win in performance critical part of the code.

Complete code you can find on [my github account](https://github.com/dendibakh/prep/blob/master/SmallVector.cpp).
