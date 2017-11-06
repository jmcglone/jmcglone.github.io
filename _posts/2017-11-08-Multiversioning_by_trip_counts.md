---
layout: post
title: Vectorization part6. Multiversioning by trip counts.
tags: default
---

In this post we will dig deep into the different type of multiversioning. This time we will look at creating multiple versions of the same loop that have different trip counts. If you haven't read [part 4: vectorization width](https://dendibakh.github.io/blog/2017/11/02/Vectorization_width) yet I encourage you to do that, because we will use knowledge form this post a lot.

In the post that I mentioned above I showed how it can be beneficial to optimize your function if you know the data you are working with. Specifically, in the section "Why we care about vectorization width?" I left off on the case when there are two different trip counts and you can't just optimize for one of it. Let's get back to this case. 

I decided to write a benchmark to show how we can use the knowledge of our data to improve performance.
Here is my baseline code:

```cpp
void add_arrays_scalar(unsigned char* a, unsigned char* b, unsigned n)
{
  unsigned chunks = 32 / n;
  for (unsigned k = 0; k < chunks; ++k)  
  {
    for (unsigned i = 0; i < n; ++i)  
      a[i] += b[i];
    a += n;
    b += n;
  }
}
```

This code processes two 32-byte arrays in chunks, specified by `n`. So, for `n = 4` there will be 8 4-byte chunks with 8 outer loop iterations.
Example is obviously contrived, but it is quite common for image processing when pixels are processed by chunks with some stride. I have seen real world code examples when this code makes sense and improvement that we will see in this post is valid.

Let's say we know all possible values for `n`. They are 4, 8 and 16. Invocation of this function looks like this:
```cpp
add_arrays_scalar(a, b, 4); // 8 inner loop iters (trip count = 4)
add_arrays_scalar(a, b, 8); // 4 inner loop iters (trip count = 8)
add_arrays_scalar(a, b, 16);// 2 inner loop iters (trip count = 16)
```

By default `clang 5.0` autovectorize the inner loop with vectorization width = 32 and interleaved by a factor of 4, so processing 128 bytes in one iteration. Also it does [multiversioning by DD](https://dendibakh.github.io/blog/2017/11/03/Multiversioning_by_DD), i.e. creating two scalar version of the loop unrolled by a factor of 8 with a run-time trip count dispatching. The latter simply means that there are two scalar versions: one is unrolled by a factor of 8 and second is no unrolled, processing one byte at a time (sort of a fallback option).

If we profile the benchmark we will notice that vector code is completely cold. Well, that's not surprise, because all our possible trip counts are smaller that 128 (`vectorization width * interleave factor`). For `n = 8,16` scalar unrolled version is used and for `n = 4` scalar basic version is used.

Another thing worth to mention is that those function invocations have different weights. Because for `n = 4` inner loop is executed 8 times and for `n = 16` only 2. That's why the fact that our function calls with `n = 4` are executed by a simple scalar loop version (processing element by element) hurts our performance more than if we would miss using unrolled loop in the case `n = 16`. The reasoning behind this is for larger trip counts less amount of branch instructions are executed. We will see the prove for that when we will try to optimize our function for different trip counts.

So, I tried another 3 ways to optimize the function:
- Vectorization width = 4
- Vectorization width = 8
- Vectorization width = 16
- Multiversioning by all possible trip counts.

First three versions try to optimize for specific trip count by adding pragma to the inner loop:
```cpp
#pragma clang loop vectorize(enable) vectorize_width(X) interleave(disable) unroll(disable)
```
, where X is the vectorization width. As you can see I disabled unrolling and interleaving, because otherwise clang will do this and I will not get the hit in vector version of the loop.

The last version (multiversioning by trip counts) looks like this:
```cpp
void add_arrays_multiver_by_trip_counts(unsigned char* a, unsigned char* b, unsigned n)
{
  unsigned chunks = 32 / n;
  for (unsigned k = 0; k < chunks; ++k)  
  {
    if (n == 4)
    {
      #pragma clang loop vectorize(enable) vectorize_width(4) interleave(disable) unroll(disable)
      for (unsigned i = 0; i < 4; ++i) 
        a[i] += b[i];
    }
    else if (n == 8)
    {
      #pragma clang loop vectorize(enable) vectorize_width(8) interleave(disable) unroll(disable)
      for (unsigned i = 0; i < 8; ++i) 
        a[i] += b[i];
    }
    else if (n == 16)
    {
      #pragma clang loop vectorize(enable) vectorize_width(16) interleave(disable) unroll(disable)
      for (unsigned i = 0; i < 16; ++i) 
        a[i] += b[i];
    }
    else
    {
      for (unsigned i = 0; i < n; ++i)  
        a[i] += b[i];
    }
    a += n;
    b += n;
  }
}
```

All code for the benchmark can be found [here].
Let's see on the measurements:

```
measurements
```

If we profile case by case we will spot this picture:
- Vectorization width = 4 : scalar code is cold, which is good, but we are processing only 4 bytes per iteration. We can do better for trip counts 8,16.
- Vectorization width = 8 : scalar code is hot for trip count = 4. For trip counts 8,16 vectorized version is used. But we missed using vector version for the trip count with the highest weight (`n = 4`).
- Vectorization width = 8 : scalar code is hot for trip counts 4,8. We are executing vector version for trip count = 16, but that still performes bad.
- Multiversioning be trip count : scalar code is cold. All 3 possible trip counts use it's own (specifically optimized) vector version of the loop, which gives us the most performance in this case.

Add some conclusion

In conclusion I want to leave a link to a great talk by Mike Acton on data-oriented design. Want performance - know your data.

### All posts from this series:
1. [Vectorization intro](https://dendibakh.github.io/blog/2017/10/24/Vectorization_part1).
2. [Vectorization warmup](https://dendibakh.github.io/blog/2017/10/27/Vectorization_warmup).
3. [Checking compiler vectorization report](https://dendibakh.github.io/blog/2017/10/30/Compiler-optimization-report).
4. [Vectorization width](https://dendibakh.github.io/blog/2017/11/02/Vectorization_width).
5. [Multiversioning by data dependency](https://dendibakh.github.io/blog/2017/11/03/Multiversioning_by_DD).
6. Multiversioning by trip counts (this article).
7. General tips for writing vectorizable code.
