---
layout: post
title: Vectorization part4. Vectorization Width.
tags: default
---

In my previous posts we have seen somewhat basic examples of loop vectorization. In this post we will go deeper in this fun stuff. In this post I will show multiple ways for the compiler to vectorize the same loop.

Usually compiler knowns better if it is beneficial to do vectorization (vs. scalar). Or maybe scalar version with good unrolling factor will do a better job. Or maybe we can vectorize the loop and then do unrolling. Or maybe interleaving will help more (see below in this article for an example). OMG. So in base case you should let compiler do the job. Every decent compiler has internal cost model which it uses to make good decisions about vectorization/unrolling, etc.

However, compiler is not always getting it right. When good decision making requires introspection (for example knowing how much loop iterations there will be) compiler can make not the best choice. Imagine code like this (as always [link to godbolt](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(j:1,source:'void+add_arrays(unsigned*+a,+unsigned*+b,+unsigned+n)%0A%7B%0A++++for+(unsigned+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)+%0A%09%09a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),header:(),k:33.333333333333336,l:'4',m:100,n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang500,filters:(b:'1',binary:'1',commentOnly:'0',demangle:'0',directives:'0',execute:'1',intel:'0',trim:'0'),libs:!(),options:'-O3+-march%3Dcore-avx2',source:1),l:'5',n:'0',o:'x86-64+clang+5.0.0+(Editor+%231,+Compiler+%231)',t:'0')),k:33.333333333333336,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:opt,i:(compilerName:'x86-64+clang+5.0.0',editorid:1,j:1,source:'%23include+%3Ccstddef%3E%0A%0Avoid+add_arrays(unsigned*+a,+unsigned*+b,+unsigned+n)%0A%7B%0A++++for+(unsigned+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)+%0A%09%09a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09'),l:'5',n:'0',o:'x86-64+clang+5.0.0+Opt+Viewer+(Editor+%231,+Compiler+%231)',t:'0')),k:33.33333333333333,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4)):
```cpp
void add_arrays(unsigned* a, unsigned* b, unsigned n)
{
  for (unsigned i = 0; i < n; ++i) 
    a[i] += b[i];
}
```

Kind of an easy code. But, as you can see the trip count `n` (number of iterations) is unknown. This makes compiler guess what is the number of iterations. If it is just a constant passing as an argument to a function call - no problem, compiler will propagate that (if it won't be a big chain of invocations). What if there are multiple calls with two different constants - slightly more complex, but still compiler knows everything it needs to know to make a good decision. But when the trip count is coming from some heavy computation or even from IO, compiler is just throwing up hands and do what it think will work good on the average.

In this case `clang 5.0` decided to vectorize the function using `AVX` instructions (`ymm` registers with 256 bits capacity) and unroll it by a factor of 8. Output from a [compiler otp report](https://dendibakh.github.io/blog/2017/10/30/Compiler-optimization-report):
```
Passed - vectorized loop (vectorization width: 8, interleaved count: 4)
```
*Warning*: Don't fall into a trap here, compiler explorer will show additional output, but this output is related to scalar version of the loop:
```
Passed - unrolled loop by a factor of 8 with run-time trip count
```

You can see the same reports if you use `-Rpass*` option with `loop-vectorize` and `loop-unroll` parameters (see my [previous post](https://dendibakh.github.io/blog/2017/10/30/Compiler-optimization-report)).

Let's check assembly to see if it matches the report:
```asm
.LBB0_12: # =>This Inner Loop Header: Depth=1
  vmovdqu ymm0, ymmword ptr [rax - 96]
  vmovdqu ymm1, ymmword ptr [rcx - 64]
  vmovdqu ymm2, ymmword ptr [rcx - 32]
  vmovdqu ymm3, ymmword ptr [rcx]
  vpaddd ymm0, ymm0, ymmword ptr [rcx - 96]
  vpaddd ymm1, ymm1, ymmword ptr [rax - 64]
  vpaddd ymm2, ymm2, ymmword ptr [rax - 32]
  vpaddd ymm3, ymm3, ymmword ptr [rax]
  vmovdqu ymmword ptr [rcx - 96], ymm0
  vmovdqu ymmword ptr [rcx - 64], ymm1
  vmovdqu ymmword ptr [rcx - 32], ymm2
  vmovdqu ymmword ptr [rcx], ymm3
  sub rax, -128
  sub rcx, -128
  add r10, -32
  jne .LBB0_12
```
This is not super complicated piece of assembly, but it is interesting in a couple of ways. 
Basic observations:
1. We can spot how compiler do array indexing: `rax - 96`, `rax - 64`, etc. Natural way is to do forward indexing: `rax + 0`, `rax + 32`, etc. But okay, I actually don't know what is the reason behind this.
2. Addition is done in a weird way: `sub rax, -128`. But it is done for having more compact code. `-128` fits in one byte (two's complement), but 128 needs two bytes. Thanks for @simonask at [cpplang.slack.com](https://cpplang.slack.com).
3. `r10` is just a counter, not used in offsets or computation. `rax` indexes `b[]` and `rcx` indexes `a[]`.

Besides that we see that this loop is adding 32 unsigned integers on every iteration. Loop is unrolled by a factor of 4. **Vectorization width** of 8 is calculated like this: `256 (size of ymm register in bits) / 32 (size of unsigned in bits) = 8`. So in this case it tells us how many elements fits in one vector register that was chosen by th e compiler. Not super fancy, but keep on reading, its not all. **Vectorization width** has another quite interesting property.

### Interleaving

Interleaving implicitly denotes the unrolled factor, which is 4 in the example above. Interleaving means that unrolled iterations are interleaved within a loop. In this example it first load 4 `ymmword`s (256 bits) from memory, starting all 4 iterations in parallel. Then it makes 4 additions again kinda in parallel. Then it does 4 write backs. Clang 5.0 always do interleaving for vectorized version of this loop, however version with no interleaving would look like this:
- Load a[0-7]
- Add b[0-7], a[0-7]
- Store b[0-7]
- Load a[8-15]
- Add b[8-15], a[8-15]
- Store b[8-15]
- etc.

Interleaving in some cases makes better utilization of a CPU resources, however it adds more register pressure, because we are doing more work in parallel.

### Why we care about vectorization width?

Now, lets see how good compiler did for this code. We will fall into vectorized version of a loop if we have at least 32 loop iterations. If the trip count for this loop is always 16, but compiler does not know that (say, it comes from configuration file) then we will fall down to the scalar version. And if it is the hot place in our application, than this will cause us significant performance hit. This is actually a call why you should use library functions like `memset`, `memcpy`, and STL algorithms - because they are heavily optimized for such cases.

If you know that your function will always has the same trip count, say 16, then you can specifically tune it with the method I will describe further. If you have multiple trip counts, say 8 and 16, you can tune it as well, but I will leave this for the future article, namely "Multiversioning by trip counts".

### Vectorization width tuning

In clang one can control vectorization width with the following pragma:
```cpp
#pragma clang loop vectorize_width(4)
```
This will implicitly tell llvm that vectorization of the loop is enabled and the width is 4. More on this you can read [on llvm site](https://llvm.org/docs/Vectorizers.html#pragma-loop-hint-directives). 

Here is the [link to godbolt](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(j:1,source:'void+add_arrays(unsigned*+a,+unsigned*+b,+unsigned+n)%0A%7B%0A%09%23pragma+clang+loop+vectorize_width(4)%0A++++for+(unsigned+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)+%0A%09%09a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),header:(),k:33.333333333333336,l:'4',m:100,n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang500,filters:(b:'1',binary:'1',commentOnly:'0',demangle:'0',directives:'0',execute:'1',intel:'0',trim:'0'),libs:!(),options:'-O3+-march%3Dcore-avx2',source:1),l:'5',n:'0',o:'x86-64+clang+5.0.0+(Editor+%231,+Compiler+%231)',t:'0')),k:33.333333333333336,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:opt,i:(compilerName:'x86-64+clang+5.0.0',editorid:1,j:1,source:'%23include+%3Ccstddef%3E%0A%0Avoid+add_arrays(unsigned*+a,+unsigned*+b,+unsigned+n)%0A%7B%0A++++for+(unsigned+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)+%0A%09%09a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09'),l:'5',n:'0',o:'x86-64+clang+5.0.0+Opt+Viewer+(Editor+%231,+Compiler+%231)',t:'0')),k:33.33333333333333,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4) with this change. Essentially what has changed is that now llvm uses SSE registers instead of AVX to do the job, so processing 16 unsigned integers in one loop iteration (previously 32). This will enable using vectorized version for arrays of 16+ elements.

If we set vectorization width greater than what `ymm(AVX)`/`zmm(AVX-512)` can handle, than it is a signal for llvm to unroll the loop. See example with `vectorize_width(64)`: [link to godbolt](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(j:1,source:'void+add_arrays(unsigned*+a,+unsigned*+b,+unsigned+n)%0A%7B%0A%09%23pragma+clang+loop+vectorize_width(64)%0A++++for+(unsigned+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)+%0A%09%09a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),header:(),k:33.333333333333336,l:'4',m:100,n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang500,filters:(b:'1',binary:'1',commentOnly:'0',demangle:'0',directives:'0',execute:'1',intel:'0',trim:'0'),libs:!(),options:'-O3+-march%3Dcore-avx2',source:1),l:'5',n:'0',o:'x86-64+clang+5.0.0+(Editor+%231,+Compiler+%231)',t:'0')),k:33.333333333333336,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:opt,i:(compilerName:'x86-64+clang+5.0.0',editorid:1,j:1,source:'%23include+%3Ccstddef%3E%0A%0Avoid+add_arrays(unsigned*+a,+unsigned*+b,+unsigned+n)%0A%7B%0A++++for+(unsigned+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)+%0A%09%09a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09'),l:'5',n:'0',o:'x86-64+clang+5.0.0+Opt+Viewer+(Editor+%231,+Compiler+%231)',t:'0')),k:33.33333333333333,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4). Here llvm uses AVX registers and loop was unrolled by a factor of 8 (previously 4).

If we set vectorization width smaller than what `xmm (SSE)` register can handle, than llvm will do meaningful work on some part of xmm register. See example with `vectorize_width(2)`: [link to godbolt](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(j:1,source:'void+add_arrays(unsigned*+a,+unsigned*+b,+unsigned+n)%0A%7B%0A%09%23pragma+clang+loop+vectorize_width(2)%0A++++for+(unsigned+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)+%0A%09%09a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),header:(),k:33.333333333333336,l:'4',m:100,n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang500,filters:(b:'1',binary:'1',commentOnly:'0',demangle:'0',directives:'0',execute:'1',intel:'0',trim:'0'),libs:!(),options:'-O3+-march%3Dcore-avx2',source:1),l:'5',n:'0',o:'x86-64+clang+5.0.0+(Editor+%231,+Compiler+%231)',t:'0')),k:33.333333333333336,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:opt,i:(compilerName:'x86-64+clang+5.0.0',editorid:1,j:1,source:'%23include+%3Ccstddef%3E%0A%0Avoid+add_arrays(unsigned*+a,+unsigned*+b,+unsigned+n)%0A%7B%0A++++for+(unsigned+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)+%0A%09%09a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09'),l:'5',n:'0',o:'x86-64+clang+5.0.0+Opt+Viewer+(Editor+%231,+Compiler+%231)',t:'0')),k:33.33333333333333,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4). You can spot inlined comments from the compiler like:
```asm
vmovq xmm0, qword ptr [rax - 24] # xmm0 = mem[0],zero
```
It means that CPU only load `qword(8 bytes)` into the `xmm0` register (half of it's capacity), filling the rest of it with zeros. Quite smart in my opinion! GCC 8.0 is not able to do that yet. For the same code gcc able to vectorize the loop with the minimum width of 4. See [this thread](https://gcc.gnu.org/ml/gcc/2017-10/msg00174.html) in gcc mailing list.

In gcc it can be controlled with `#pragma omp simd` with `simdlen` clause. More information [here](http://bisqwit.iki.fi/story/howto/openmp/#SimdlenClauseOpenmp 4 5).

As a final note, I want to say, that in gcc there is different name for width. It's called vectorization factor (`vf`). And in Intel compiler (icc) it is called vector length (`VL`).

### All posts from this series:
1. [Vectorization intro](https://dendibakh.github.io/blog/2017/10/24/Vectorization_part1).
2. [Vectorization warmup](https://dendibakh.github.io/blog/2017/10/27/Vectorization_warmup).
3. [Checking compiler vectorization report](https://dendibakh.github.io/blog/2017/10/30/Compiler-optimization-report).
4. Vectorization width (this article).
5. Multiversioning by data dependency (DD).
6. Multiversioning by trip counts.
7. General tips for writing vectorizable code.

