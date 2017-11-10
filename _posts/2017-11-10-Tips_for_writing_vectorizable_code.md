---
layout: post
title: Vectorization part7. Tips for writing vectorizable code.
tags: default
---

This post is wrapping up the series. We just saw some really simple examples when vectorization either happens or not. But usually you have more complicated code. What to do in this case, how make use of vectorization capabilities of your CPU?

To best answer this question I want to highlight the typical reasons for not vectorized code and guidlines for writing vectorizable code.

### Typical reasons for loop not being vectorized.

1. Low trip count
2. Not Inner Loop
3. Existence of vector dependence
4. Vectorization possible but seems inefficient
5. Condition may protect exception
6. Data type unsupported
7. Subscript too complex
8. Unsupported loop structure
9. Statement inside the loop unsuited for vectorization

### General tips for writing vectorizable code.

1. Favor simple `for` loops
2. Write straight line code. Avoid:
- Function calls
- Branches that cannot be treated as masked assignments
3. Avoid dependencies between loop iterations
- Avoid read-after-write dependencies
4. Prefer array notation to the use of pointers
- Or provide help for compiler to understand
- Try to use the loop index directly in array subscripts, instead of incrementing a separate counter for use as an array address
5. Use efficient memory addresses
- Favor inner loops with unit stride
- Minimize indirect addressing
6. Align your data where possible to some boundary (32 bytes in case of AVX)

However, the main advice is: see [compiler opt reports](https://dendibakh.github.io/blog/2017/10/30/Compiler-optimization-report) to understand what compiler did for you. If you measured and your code stil

### Other resources

Some items from the two checklists below were taken from [Intel Compiler Autovectorization Guide](https://software.intel.com/sites/default/files/m/4/8/8/2/a/31848-CompilerAutovectorizationGuide.pdf). I really recommend it, even though it is slightly outdated.

Specifically I want to point out that compilers can do all sorts of [loop transformations](https://en.wikipedia.org/wiki/Loop_optimization) to make vectorization possible. I recommend to at least familiarize yourself with the basic loop transformations. For example, compiler can perform some of them if it will help to eliminate some loop dependency. Doing so will enable vectorization.

This is really nice article with lots of examples: [Crunching numbers with AVX and AVX2](https://www.codeproject.com/Articles/874396/Crunching-Numbers-with-AVX-and-AVX). It is a good guide if you want to try out writing vector intrinsics. This post has nice pictures of how some particular hardware instruction works.

[Vectorization codebook](https://software.intel.com/sites/default/files/managed/f5/d2/DPD_Vectorization_Codebook.pdf) has rather high-level view for the topic with links to the more detailed documents.

### All posts from this series:
1. [Vectorization intro](https://dendibakh.github.io/blog/2017/10/24/Vectorization_part1).
2. [Vectorization warmup](https://dendibakh.github.io/blog/2017/10/27/Vectorization_warmup).
3. [Checking compiler vectorization report](https://dendibakh.github.io/blog/2017/10/30/Compiler-optimization-report).
4. [Vectorization width](https://dendibakh.github.io/blog/2017/11/02/Vectorization_width).
5. [Multiversioning by data dependency](https://dendibakh.github.io/blog/2017/11/03/Multiversioning_by_DD).
6. [Multiversioning by trip counts](https://dendibakh.github.io/blog/2017/11/09/Multiversioning_by_trip_counts).
7. Tips for writing vectorizable code (this article).
