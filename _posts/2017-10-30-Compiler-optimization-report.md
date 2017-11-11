---
layout: post
title: Vectorization part3. Compiler report.
tags: default
---

This post will be short but it is quite important to know about compiler optimization reports because it can save you a lot of time.
Sometimes you want to know if your loop was vectorized or not, unrolled or not. If it was unrolled, what is the unrol factor? Was your function inlined? There is a hard way - by looking at the assembly. This can be a really hard if the function is big, or it has many loops that were also vectorized, or if compiler created multiple versions of the same loop, OMG.

There is more convienient way to know that - by checking compiler report. For example, for the following code ([link to godbolt](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(j:1,source:'%23include+%3Ccstddef%3E%0A%0Avoid+add_arrays(float*+a,+float*+b,+std::size_t+n)%0A%7B%0A++++for+(std::size_t+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)%0A++++++++a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09%0A'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),header:(),k:33.72686813932536,l:'4',m:100,n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang500,filters:(b:'0',binary:'1',commentOnly:'0',demangle:'0',directives:'0',execute:'1',intel:'0',trim:'0'),libs:!(),options:'-O3',source:1,wantOptInfo:'0'),l:'5',n:'0',o:'x86-64+clang+5.0.0+(Editor+%231,+Compiler+%232)',t:'0')),k:32.939798527341324,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:opt,i:(compilerName:'x86-64+clang+5.0.0',editorid:1,j:2,source:'%23include+%3Ccstddef%3E%0A%0Avoid+add_arrays(float*+a,+float*+b,+std::size_t+n)%0A%7B%0A++++%23pragma+clang+loop+vectorize(enable)+vectorize_width(LEN)%0A++++for+(std::size_t+i+%3D+0%3B+i+%3C+n%3B+%2B%2Bi)%0A++++++++a%5Bi%5D+%2B%3D+b%5Bi%5D%3B%0A%7D%09%0A'),l:'5',n:'0',o:'x86-64+clang+5.0.0+Opt+Viewer+(Editor+%231,+Compiler+%232)',t:'0')),k:33.33333333333333,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4)):

```cpp
void add_arrays(float* a, float* b, std::size_t n)
{
    for (std::size_t i = 0; i < n; ++i)
        a[i] += b[i];
}
```

To emit opt report in clang you need to pass [-Rpass*](https://llvm.org/docs/Vectorizers.html#diagnostics) flags:

```
$ clang -O3 -Rpass-analysis=loop-vectorize -Rpass=loop-vectorize -Rpass-missed=loop-vectorize
a.cpp:5:5: remark: vectorized loop
  (vectorization width: 4, interleaved count: 2) [-Rpass=loop-vectorize]
    for (std::size_t i = 0; i < n; ++i)
    ^
```

Great, so at least now we know that our loop was vectorized with a vectorization width = 4 (see next posts what that mean) and vectorized loop iterations were interleaved with count = 2.
You still may want to check assembly, as it might surprise you in some cases, but it gives a good starting point and quick way to check things. However, it requires a little bit of experience to understand what those parameters mean to fully leverage compiler opt reports.

In compiler explorer there is a cool opt report viewer. You need just to hover your mouse over the line with the code and you will see all high-level optimizations that were performed on that loop.

Sometimes, vectorization fails. For example:

```
void add_arrays(float* a, float* b, std::size_t n)
{
    float agg = 0.0;
    for (std::size_t i = 0; i < n; ++i)
    {
        a[i] += b[i];
        agg += b[i];
        if (agg > 100)
            break;
    }
}
```
Opt report:
```
a.cpp:6:5: remark: loop not vectorized: value that could not be identified as reduction is used outside the loop [-Rpass-analysis=loop-vectorize]
    for (std::size_t i = 0; i < n; ++i)
    ^
a.cpp:6:5: remark: loop not vectorized: could not determine number of 
    loop iterations [-Rpass-analysis=loop-vectorize]
a.cpp:6:5: remark: loop not vectorized [-Rpass-missed=loop-vectorize]
```

Sometimes you will see reports about missed vectorization opportunities because it was not beneficial to vectorize the loop. For example, because there were not enough iterations. Vectorizer has some internal cost model, which compiler uses to make decision about vectorizing particular loop.

Situation gets a little bit compilcated when you are using LTO. When you are building with LTO, clang does not produce the binary files, but bitcode (intermediate representation) which will be combined into executable on linking stage. So, the final decision about whether it's beneficial to vectorize the loop or not, now may happen on the LTO stage. For example, compiler inlined the function call and now it knows all possible trip counts of the loop. So, when you pass `-Rpass*` along with `-flto` it won't print you anything. To see opt reports in this case first you need to add debug information(`-g`) to the compilation of the file you are interesting in. Lack of debug info will cause no filenames and line numbers in the report. After that, you need to pass additional options to the linking stage:
1. Gold plugin - pass `-Wl,-plugin-opt,-pass-remarks=loop-vectorize -pass-remarks-missed=.` etc.
2. LLD linker  - pass `-Wl,-mllvm -Wl,-pass-remarks=loop-vectorize -Wl,-mllvm -Wl,-pass-remarks-missed=.` etc.

### Other compilers

For gcc you need to pass `-ftree-vectorize -ftree-vectorizer-verbose=X`, where X is the verbose level. More about this [here](https://www.gnu.org/software/gcc/projects/tree-ssa/vectorization.html#using).

I find the most usable opt reports from Intel Compiler (icc). It shows if the loop was multiversioned, it has filter by the line of the code, etc. Also the issue with LTO (like in clang) works with no additional steps from the user. It remembers that user requested opt report on compilation stage and it will generate output in the text file on the linking stage (in icc it is called IPO - Inter Procedural Optimization). More links for icc [here](https://software.intel.com/en-us/node/590464) and [here](https://software.intel.com/en-us/node/522949).

### All posts from this series:
1. [Vectorization intro](https://dendibakh.github.io/blog/2017/10/24/Vectorization_part1).
2. [Vectorization warmup](https://dendibakh.github.io/blog/2017/10/27/Vectorization_warmup).
3. Checking compiler vectorization report (this article).
4. [Vectorization width](https://dendibakh.github.io/blog/2017/11/02/Vectorization_width).
5. [Multiversioning by data dependency](https://dendibakh.github.io/blog/2017/11/03/Multiversioning_by_DD).
6. [Multiversioning by trip counts](https://dendibakh.github.io/blog/2017/11/09/Multiversioning_by_trip_counts).
7. [Tips for writing vectorizable code](https://dendibakh.github.io/blog/2017/11/10/Tips_for_writing_vectorizable_code).
