---
layout: post
title: Vectorization part6. Multiversioning by trip counts.
tags: default
---

In this post we will dig deep into the different type of multiversioning. This time we will look at creating multiple versions of the same loop that have different trip counts. If you haven't read [part 4: vectorization width](https://dendibakh.github.io/blog/2017/11/02/Vectorization_width) yet I encourage you to do that, because we will use knowledge form this post a lot.

In the post that I mentioned above I showed how it can be beneficial to optimize your function if you know the data you are working with. Specifically, in the section "Why we care about vectorization width?" I left off on the case when there are two different trip counts and you can't just optimize for one of it. Let's get back to this case. Here is the code:

```cpp
void add_arrays(unsigned* a, unsigned* b, unsigned n)
{
  for (unsigned i = 0; i < n; ++i) 
    a[i] += b[i];
}
```

:

### All posts from this series:
1. [Vectorization intro](https://dendibakh.github.io/blog/2017/10/24/Vectorization_part1).
2. [Vectorization warmup](https://dendibakh.github.io/blog/2017/10/27/Vectorization_warmup).
3. [Checking compiler vectorization report](https://dendibakh.github.io/blog/2017/10/30/Compiler-optimization-report).
4. [Vectorization width](https://dendibakh.github.io/blog/2017/11/02/Vectorization_width).
5. [Multiversioning by data dependency](https://dendibakh.github.io/blog/2017/11/03/Multiversioning_by_DD).
6. Multiversioning by trip counts (this article).
7. General tips for writing vectorizable code.
