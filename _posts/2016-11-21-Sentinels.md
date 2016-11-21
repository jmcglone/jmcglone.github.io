---
layout: post
title: Sentinels.
tags: default
---

Today I would like to show one interesting techique for optimizing your algorithms. This technique is called sentinels.
Sentinel is a special thing that marks the end of the sequence. The natural example here example is \'\0\' terminator for a C-string.

Let's consider function that only searches for some value in the array:

```cpp
bool find_benchmark(int* arr, size_t size, int val)
{
  for (size_t i = 0; i < size; ++i)
  {
    if (val == arr[i])
      return true;
  }
  return false;
}
```

1. We check all elements for equality with out target.
2. At each iteration we check if we reach the end of our array.

We can't put away equality checks, but we can get rid of checking bound by using sentinel.

The idea is to insert the number we are looking for at the end of the array.
This will garanty that in worst case we will look through entire array, but we will always find the number we are looking for.

If so, than we can get rid of checking out of bounds condition, making our loop naturally infinite. We can be sure that our infinite loop will finish, because we know there is a value we are looking for.

```cpp
// Assumption made: array has one empty slot for insertion our sentinel.
bool sentinel_find_benchmark(int* vect, size_t size, int val)
{
  vect[size] = val;
  size_t i = 0;
  for (;;++i)
  {
    if (val == vect[i])
    {
      if (i == size)
        return false;
      else
        return true;
    }
  }
  return false;
}
```

This code is far from ideal, but it shows the idea behind the sentinels.
In general there are much more concerns you should care about:

1. If the const array is passed, you are not allowed to change it, thus require a copy to be made.
2. If the non-const vector is passed, inserting a new element can cause reallocation -> invalidating iterators.
3. Elements of the array can be non default-constructible, preventing for creation of a sentinel. 

I ran a benchmark test (search failure) with 1000 elements 1000000 times:

1. With no optimizations (-O0) sentinels version was 9% faster.
2. With -O3 sentinels version was 21% faster.

To understand why this works lets look at the assembly.

You can check all assembly output here: [godbolt.org](https://godbolt.org/g/N8oDmZ).

Comparing effective loops of two algoritms we can see that one additional check eliminated:

```asm
| Simple find                        | Find with sentinel              |
|:----------------------------------:|:-------------------------------:|
|Effective loop:                     | Effective loop:                 |
|  mov     rax, QWORD PTR [rbp-8]    |                                 |
|  cmp     rax, QWORD PTR [rbp-32]   |                                 |
|  jnb     .L2                       |                                 |
|  mov     rax, QWORD PTR [rbp-8]    |  mov     rax, QWORD PTR [rbp-8] | 
|  lea     rdx, [0+rax*4]            |  lea     rdx, [0+rax*4]         |
|  mov     rax, QWORD PTR [rbp-24]   |  mov     rax, QWORD PTR [rbp-24]|
|  add     rax, rdx                  |  add     rax, rdx               |
|  mov     eax, DWORD PTR [rax]      |  mov     eax, DWORD PTR [rax]   |
|  cmp     eax, DWORD PTR [rbp-36]   |  cmp     eax, DWORD PTR [rbp-36]|
|  jne     .L3                       |  jne     .L2                    |
```

Complete set of functions as well as the benchmarking tests can be found [here](https://github.com/dendibakh/prep/blob/master/sentinels.cpp).

Sentinels could be used even for speed up quicksort. See this great [talk by Andrei Alexandrescu on ACCU 2016](https://www.google.fi/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwiRm_TI0bnQAhVW6WMKHUx1CLgQtwIIGzAA&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DAxnotgLql0k&usg=AFQjCNHczAs076PR3dA15XoDlAtDGxcTwg&sig2=bVVhiEjuICruRhyGkKwH3Q).

