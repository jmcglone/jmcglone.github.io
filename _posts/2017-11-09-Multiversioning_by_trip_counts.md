---
layout: post
title: Vectorization part6. Multiversioning by trip counts.
categories: [vectorization]
---

In this post we will dig deep into the different type of multiversioning. This time we will look at creating multiple versions of the same loop that have different trip counts. If you haven't read [part 4: vectorization width]({{ site.url }}/blog/2017/11/02/Vectorization_width) yet I encourage you to do that, because we will use knowledge form this post a lot.

In the post that I mentioned above I showed how it can be beneficial to optimize your function if you know the data you are working with. Specifically, in the section "Why we care about vectorization width?" I left off on the case when there are two different trip counts and you can't just optimize for one of it. Let's get back to this case. 

### Baseline

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
// 1. All trip counts (tcXX variables) are read from the file, 
//   so compiler doesn't know them at compile time
// 2. a and b have random numbers and values can wrap around,
//   we don't care about it now.

add_arrays_scalar(a, b, tc4);  // tc4  = 4  (8 inner loop iters)
add_arrays_scalar(a, b, tc8);  // tc8  = 8  (4 inner loop iters)
add_arrays_scalar(a, b, tc16); // tc16 = 16 (2 inner loop iters)

// In the end I ensure the results are not optimized away.
```

Compiler options are: `-O3 -march=core-avx2`.

By default `clang 5.0` autovectorize the inner loop with vectorization width = 32 and interleaved by a factor of 4, so processing 128 bytes in one iteration. Also it does [multiversioning by DD]({{ site.url }}/blog/2017/11/03/Multiversioning_by_DD), i.e. creating two scalar version of the loop unrolled by a factor of 8 with a run-time trip count dispatching. The latter simply means that there are two scalar versions: one is unrolled by a factor of 8 and second is no unrolled, processing one byte at a time (sort of a fallback option).

All code for the benchmark can be found [here](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/Multiversioning_by_trip_counts).

If we profile the baseline case we will notice that vector code is completely cold. Well, that's not surprising, because all our possible trip counts are smaller that 128 (`vectorization width * interleave factor`). For `n = 8,16` scalar unrolled version is used and for `n = 4` scalar basic version is used.

Another thing worth to mention is that those function invocations have different weights. Because for `n = 4` inner loop is executed 8 times and for `n = 16` only 2. That's why the fact that our function calls with `n = 4` are executed by a simple scalar loop version (processing element by element) hurts our performance more than if we would miss using unrolled loop in the case `n = 16`. The reasoning behind this is: for the larger trip counts less amount of branch instructions are executed. We will see the prove for that when we will try to optimize our function for different trip counts.

### Attempts to improve performance

So, I tried another 3 ways to optimize the function:
- Vectorization width = 4
- Vectorization width = 8
- Vectorization width = 16
- Multiversioning by all possible trip counts.

First three versions try to optimize for specific trip count by adding pragma to the inner loop:
```cpp
#pragma clang loop vectorize(enable) vectorize_width(X)
#pragma clang loop interleave(disable) unroll(disable)
```
, where X is the vectorization width. As you can see I disabled unrolling and interleaving, because otherwise clang will do this and I will not get the hit in vector version of the loop.

The last version (multiversioning by trip counts) looks like this:
```cpp
void add_arrays_multiver_by_trip_counts(
	unsigned char* a, 
	unsigned char* b, 
	unsigned n)
{
  unsigned chunks = 32 / n;
  for (unsigned k = 0; k < chunks; ++k)  
  {
    if (n == 4)
    {
      #pragma clang loop vectorize(enable) vectorize_width(4)
      #pragma clang loop interleave(disable) unroll(disable)
      for (unsigned i = 0; i < 4; ++i) 
        a[i] += b[i];
    }
    else if (n == 8)
    {
      #pragma clang loop vectorize(enable) vectorize_width(8)
      #pragma clang loop interleave(disable) unroll(disable)
      for (unsigned i = 0; i < 8; ++i) 
        a[i] += b[i];
    }
    else if (n == 16)
    {
      #pragma clang loop vectorize(enable) vectorize_width(16)
      #pragma clang loop interleave(disable) unroll(disable)
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

### Measurements

I ran the benchmark on a Intel Core i7-6700 processor:

```
---------------------------------------------------------------
Benchmark                 Time    CPU Iterations  Throughput
---------------------------------------------------------------
Scalar                   72 ns  72 ns   96790551  370.835MB/s (baseline)
Vectorization_width_4    52 ns  52 ns  133665303  510.321MB/s (+37.6%)
Vectorization_width_8    48 ns  48 ns  146755270  559.533MB/s (+50.9%)
Vectorization_width_16   55 ns  55 ns  128159636  488.847MB/s (+31.8%)
Multiver_by_trip_counts  44 ns  44 ns  157490466  601.103MB/s (+62.1%)
```

### Justification

Our final version is 62% faster than the baseline. Let's figure out why. I profiled case by case to understand what is going on in each case:
- Vectorization width = 4 : scalar code is cold, which is good, but we are processing only 4 bytes per iteration (utilizing only `1/4` of the xmm register capacity). We can do better for trip counts 8,16.
- Vectorization width = 8 : scalar code is hot for trip count = 4. For trip counts 8,16 vectorized version is used. We missed using vector version for the trip count with the highest weight (`n = 4`). However, it was a surprise to me that this version outperforms the version optimized for `n = 4`.
- Vectorization width = 16 : scalar code is hot for trip counts 4,8. We are executing vector version only for trip count = 16. That's still ~30% better than the baseline, but still not quite super optimal.
- Multiversioning by trip count : scalar code is cold. All 3 possible trip counts use it's own (specifically optimized) vector version of the loop, which gives us the most performance in this case.

### Caveat

This post is not to encourage you to optimize every routine like this - please don't do that. Do this only if your measurements show significant benefit of such change. If your compiler is not doing the best job for your hot function probably someday it will. It's not always beneficial to vectorize loops with small trip count, sometimes it's better to do full unrolling. Compiler will be many times better than you at figuring out such things.

Also this optimization doesn't make much sense when you have big arrays. Compiler already prepared the code for it (remember that there is autovectorized version that processes 128 bytes at a time - see in the beginning of the article).

Another thing worth to mention is that in the fastest attempt there are at least 6 versions of the same loop (3 handwritten + 1 autovectorized + 1 unrolled + 1 fallback). This increases code size significantly!

In this case enabling LTO doesn't make much of a difference (results are mostly the same). 

However, if you replace the trip count arguments with constant values (`4,8,16`) and enable LTO (pass `-flto` flag), then compiler will propagate this constant into the function and scalar version will beat all the others! I profiled this case and noticed that compiler recognized my dirty trick with processing array by chunks and realized that in the nutshell there is no difference between those 3 function calls - they all do the same thing.

### Final note

I want to share a great talk from CppCon 2014 by Mike Acton: [Data-Oriented Design and C++](https://www.youtube.com/watch?v=rX0ItVEVjHc). 

Want performance - know your data.

UPD: one more article related to the topic of multiversioning: [Function multi-versioning in GCC 6](https://lwn.net/Articles/691932/).

### All posts from this series:
1. [Vectorization intro]({{ site.url }}/blog/2017/10/24/Vectorization_part1).
2. [Vectorization warmup]({{ site.url }}/blog/2017/10/27/Vectorization_warmup).
3. [Checking compiler vectorization report]({{ site.url }}/blog/2017/10/30/Compiler-optimization-report).
4. [Vectorization width]({{ site.url }}/blog/2017/11/02/Vectorization_width).
5. [Multiversioning by data dependency]({{ site.url }}/blog/2017/11/03/Multiversioning_by_DD).
6. Multiversioning by trip counts (this article).
7. [Tips for writing vectorizable code]({{ site.url }}/blog/2017/11/10/Tips_for_writing_vectorizable_code).
