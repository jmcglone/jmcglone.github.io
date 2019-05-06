---
layout: post
title: Performance analysis and tuning contest &#35&#50.
categories: contest
---

**Contents:**
* TOC
{:toc}

Welcome to the second edition of my performance analysis and tuning contest. If you see this post and haven't read my initial post about the [contest]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest), I encourage you to read it first. 

------
**Subscribe to my [mailing list]({{ site.url }}/blog/2019/04/10/Performance-analysis-and-tuning-contest-2#mc_embed_signup) to participate!**

------

The benchmark for the 2nd edition is 7zip-benchmark from [LLVM test-suite](https://github.com/llvm-mirror/test-suite). Yes, this time we have a serious challenge and I expect it will be lots of fun, but at the same time lots of new things to learn!

7-Zip is a well-known peace of software. This is a file archiver with a high compression ratio. 7-Zip which supports different compression algorithms and formats.

There are two tests combined in the benchmark:
1. Compression with LZMA method
2. Decompression with LZMA method

Documentation for this benchmark can be found [here](https://documentation.help/7-Zip/documentation.pdf) (see chapter "Benchmark", page 25).

### Quickstart

To download and build the benchmark do the following:
```bash
$ git clone https://github.com/llvm-mirror/test-suite
$ mkdir build
$ cd build
$ cmake -DTEST_SUITE_COLLECT_CODE_SIZE=OFF -DTEST_SUITE_BENCHMARKING_ONLY=ON -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_C_FLAGS="-O3 -march=core-avx2" -DCMAKE_CXX_FLAGS="-O3 -march=core-avx2" ../test-suite/
$ make 7zip-benchmark -j6
```

To run the benchmark do:
```bash
$ cd MultiSource/Benchmarks/7zip
$ ./7zip-benchmark b
```

There is some amount of macroses in the benchmark, so you might want to preprocess it. Special target generated for this by cmake might be helpful, for example:
```bash
make C/LzmaDec.i
```

For building with gcc you need to revert this commit: [7ee8c3b0943f6e6c7d2180c1bd7648e27c3a19cc](https://github.com/llvm-mirror/test-suite/commit/7ee8c3b0943f6e6c7d2180c1bd7648e27c3a19cc).

Clang and gcc compilers give roughly the same score[^1], so you can choose whatever is more convenient for you.

Target machine for this edition of the contest is again Haswell CPU with 64-bit Linux. Although you can do your experiments on Windows since `cmake` is used for building the benchmark. If you choose Windows as a platform, here is the article that might be helpful: [How to collect CPU performance counters on Windows?]({{ site.url }}/blog/2019/02/23/How-to-collect-performance-counters-on-Windows).

### Couple of hints

Here is the workflow that I recommend: 

1. Collect the baseline (use `time` or analogs).
2. Find the hotspot (use `perf record`).
3. Find performance headroom
  * Take a look at the assembly and try to guess how you can do better.
  * Collect general statistics like branch mispredictions, cache-misses (use `perf stat`).
  * Run through [TMAM]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) process.
4. Fix the issue, build the benchmark, run it and compare against baseline.

I also have a few general advises:
- **Do not try to understand the whole benchmark**. For some people (including me) it's crucial to understand how every peace of code works. For the purposes of optimizing it will be wasted effort. There are CPU benchmarks with thousands LOC (like [SPEC2017](http://spec.org/cpu2017/)) it's absolutely impossible to understand them in a reasonable time. What you need to familiarize yourself with are hotspots. That's it. You most likely need to understand one function/loop which is not more than 100 LOC.
- **You have specific workload for which you optimize the benchmark**. You don't need to optimize it for any other input/workload. The main principle behind [Data-oriented design](https://en.wikipedia.org/wiki/Data-oriented_design) is that you know the data of your application.

If you feel you're stuck, don't hesitate to ask questions or look for support elsewhere. I don't have much time to answer every question promptly, but I will do my best.

__See the Q&A post about what optimizations are [allowed]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest#q5-what-optimizations-are-allowed) and what [not]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest#q6-whats-not-allowed).__

### Validation

If the benchmark ran correctly it will print something like:
```
7-Zip (A) [64] 9.20  Copyright (c) 1999-2010 Igor Pavlov  2010-11-18
p7zip Version 9.20 (locale=en_US.UTF-8,Utf16=on,HugeFiles=on,1 CPU)

RAM size:     128 MB,  # CPU hardware threads:   1
RAM usage:    107 MB,  # Benchmark threads:      1

Dict        Compressing          |        Decompressing
      Speed Usage    R/U Rating  |    Speed Usage    R/U Rating
       KB/s     %   MIPS   MIPS  |     KB/s     %   MIPS   MIPS

22:    5623    99   5543   5470  |    46195   101   4146   4171
23:    4982   100   5098   5076  |    45875   100   4199   4200
----------------------------------------------------------------
Avr:           99   5320   5273               100   4173   4185
Tot:          100   4746   4729
```

The benchmark shows a rating in MIPS (million instructions per second). But for our purposes this is not a good metric, since we strive for the fastest execution time. We can have higher number of instructions but lower running time. For this reason I recommend just measuring execution time.

If for some reason you did something wrong it will print:
```
Decoding Error
```

### Submissions

> __Disclaimer__: I will not use submissions in any commercial purposes.

The baseline that I will be measuring against is 'clang -O3 -march=core-avx2'. I noticed that enabling [LTO](https://en.wikipedia.org/wiki/Interprocedural_optimization) (`-flto`) doesn't bring any additional improvement, but you may add it if you want. Notice however, that it increases build time of the benchmark which is not good to doing quick experiments.

If you're willing to submit your work __subscribe to my [mailing list]({{ site.url }}/blog/2019/04/10/Performance-analysis-and-tuning-contest-2#mc_embed_signup)__ and then send all that you have via email.

__See the rules and guidelines for submissions [here]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest#q7-how-should-the-submission-look-like).__

If you are in a position of writing article with description of your findings, I highly encourage you to do so. It will be much better to have the author describe the finding in comparison with me interpreting your submission. 

**I'm collecting all your submissions until 30th April 2019.**

### Spread the word

If you know someone who might be interesting in participating in this contest, please spread the word about it!

Good luck and have fun!

__P.S.__ I have no automation for my contest yet, so if anyone knows any good service or a way to automate it using web interface, please let me know.

__P.P.S.__ I'm also open to your comments and suggestions. If you have an proposition of a benchmark for the next edition of the contest, please tell me about it.

---

## _Updated 4th May 2019_

I haven't received enough submissions for the contest so I decided not to publish the score table this time. Instead of that I will share what participants were able to find.

### Fighting branch mispredictions (+9%)

Almost every participant identified the bottleneck in the benchmark which is the amount of branch mispredictions:

```bash
$ ~/pmu-tools/toplev.py --core S0-C0 -l2 -v --no-desc taskset -c 0 ./7zip-benchmark b
S0-C0    FE             Frontend_Bound:                             13.74 +-     0.00 % Slots below
S0-C0    BAD            Bad_Speculation:                            39.32 +-     0.00 % Slots      
S0-C0    BE             Backend_Bound:                              15.61 +-     0.00 % Slots      
S0-C0    RET            Retiring:                                   31.28 +-     0.00 % Slots below
S0-C0    FE             Frontend_Bound.Frontend_Latency:             8.48 +-     0.00 % Slots below
S0-C0    FE             Frontend_Bound.Frontend_Bandwidth:           5.28 +-     0.00 % Slots below
S0-C0    BAD            Bad_Speculation.Branch_Mispredicts:         39.29 +-     0.00 % Slots       <==
S0-C0    BAD            Bad_Speculation.Machine_Clears:              0.03 +-     0.00 % Slots below
S0-C0    BE/Mem         Backend_Bound.Memory_Bound:                  7.14 +-     0.00 % Slots below
S0-C0    BE/Core        Backend_Bound.Core_Bound:                    8.47 +-     0.00 % Slots below
S0-C0    RET            Retiring.Base:                              31.15 +-     0.00 % Slots below
S0-C0    RET            Retiring.Microcode_Sequencer:                0.12 +-     0.00 % Slots below
```

If HW branch predictor can't deal with some branch there is usually not much you can do about it. Because if there would be some repeatable pattern, the HW branch predictor unit will catch it. However, it still may be a good idea to confirm that the pattern is in fact unpredictable. I wrote complete new article on how you can collect statistics for a particular branch: [Estimating branch probability using Intel LBR feature]({{ site.url }}/blog/2019/05/06/Estimating-branch-probability). 

I put all the details there, so I really encourage you to take a look at the [post]({{ site.url }}/blog/2019/05/06/Estimating-branch-probability) I just mentioned. There you will find how one can locate the branch that was mispredicted and how to find the corresponding line in source code.

So, here is the piece of code of our interest (preprocessed):
```cpp
do {
  ttt = *(prob + symbol);
  if (range < ((UInt32)1 << 24)) {
    range <<= 8;
    code = (code << 8) | (*buf++);
  };
  bound = (range >> 11) * ttt;
  if (code < bound) {             // <-- unpredictable branch
    range = bound;
    *(prob + symbol) = (UInt16)(ttt + (((1 << 11) - ttt) >> 5));
    symbol = (symbol + symbol);
  } else {
    range -= bound;
    code -= bound;
    *(prob + symbol) = (UInt16)(ttt - (ttt >> 5));
    symbol = (symbol + symbol) + 1; 
  }
} while (symbol < 0x100);
```

-How we can get rid of the branch mispredictions?

-By getting rid of the branch itself. 

-How to do that?

-One way to do this is to force compiler to generate [CMOVs](https://www.felixcloutier.com/x86/cmovcc) (Conditional Move) instead of branches.

Here is the modified code:

```cpp
do {
  ttt = *(prob + symbol);
  if (range < ((UInt32)1 << 24)) {
    range <<= 8;
    code = (code << 8) | (*buf++);
  };
  bound = (range >> 11) * ttt;
  
  Bool cond = code < bound;
  
  range = cond ? bound : (range - bound);
  UInt16 *addr = prob + symbol;
  UInt16 LHS = (UInt16)(ttt + (((1 << 11) - ttt) >> 5));
  UInt16 RHS = (UInt16)(ttt - (ttt >> 5));
  *addr = cond ? LHS : RHS;
  
  symbol = (symbol + symbol);
  symbol = cond ? symbol : symbol + 1;
  code = cond ? code : code - bound;
} while (symbol < 0x100);
```

The idea is that we compute both branches and then just select the right answer using [CMOV](https://www.felixcloutier.com/x86/cmovcc) instruction.

Note, however, there is a threshold for generating cmovs. When there are too much computations in both branches it is better to take the penalty of branch misprediction (~15-20 cycles, depending how deep is the pipeline) than executing both branches. I think this threshold is usually low, meaning that CMOV is only profitable when there are not many computations in both branches and branch is unpredictable. For further reading check this [stackoverflow](https://stackoverflow.com/questions/44754267/how-to-force-the-use-of-cmov-in-gcc-and-vs) question.

There are other similar places where branch misprediction happens inside `LzmaDec_DecodeReal()`. The best place to fix them all is to modify the `GET_BIT2` macro. You can find the patch which does that on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/2/cmov.patch) and try it yourself.

### Improving machine block placement (+1.5%)

Once the major issue (branch mispredictions) is fixed, workload starts being Frontend Bound:
```
S0-C0    FE             Frontend_Bound:       22.11 +-     0.00 % Slots       <==
S0-C0    BAD            Bad_Speculation:      17.81 +-     0.00 % Slots      
S0-C0    BE             Backend_Bound:        20.80 +-     0.00 % Slots      
S0-C0    RET            Retiring:             40.02 +-     0.00 % Slots below
```
I ran the benchmark with Profile guided optimizations[^2] (PGO) enabled and it showed slight degradation so that wasn't any helpful.

I noticed that `NORMALIZE` macro (inside `GET_BIT2` macro) is almost never executed:
```cpp
  if (range < ((UInt32)1 << 24)) { // almost always false
    range <<= 8;
    code = (code << 8) | (*buf++);
  };
```

Yet in the assembly we have this code physically residing inside the hot loop:
```
    0.00 : ┌─┬───> 4edab0:       mov    ecx,ecx		<== begin loop
    0.00 : │ │     4edab2:       movzx  eax,WORD PTR [r9+rcx*2]
    4.36 : │ │     4edab7:       cmp    ebp,0xffffff
    0.66 : │ │ ┌── 4edabd:       ja     4edad0 
    0.00 : │ │ │   4edabf:       shl    ebp,0x8		<== NORMALIZE body
    0.00 : │ │ │   4edac2:       shl    r10d,0x8
    0.00 : │ │ │   4edac6:       movzx  edx,BYTE PTR [r8]
    0.00 : │ │ │   4edaca:       inc    r8
    0.00 : │ │ │   4edacd:       or     r10d,edx
    0.00 : │ │ └─> 4edad0:       mov    edx,ebp
    0.00 : │ │     4edad2:       shr    ebp,0xb
    0.00 : │ │     4edad5:       imul   ebp,eax
           ...
```

You see, we have taken branch in the hot region. If we invert the control flow we will have hot fall through code. See details in the post [Machine code layout optimizations]({{ site.url }}/blog/2019/03/27/Machine-code-layout-optimizatoins#basic-block-placement). We can insert `Likely/Unlikely` compiler hints to make things better:
```cpp
  if (__builtin_expect(range < ((UInt32)1 << 24), 0)) { // unlikely to be true
    range <<= 8;
    code = (code << 8) | (*buf++);
  };
```

With this information compiler is able to move the body of `NORMALIZE` macro out of the hot region. The patch that does that is on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/2/unlikely_normalize.patch).

### Reducing code size of the hot code (+0.5%)

I found this somewhat hot loop in `LzmaDec_DecodeReal()`:
```cpp
// C/LzmaDec.c
393           dicPos += curLen;
394           do
395             *(dest) = (Byte)*(dest + src);
396           while (++dest != lim);
```

The scalar (not unrolled) version of it was firing although compiler prepared vectorized and unrolled + slp-vectorized versions of it. See examples and more information in my article: [Vectorization part6. Multiversioning by trip counts]({{ site.url }}/blog/2017/11/09/Multiversioning_by_trip_counts).

I did several experiments of unrolling and vectorizing the loop [^3] with different factors but none of them gave me any performance boost. I soon figured out that this loop has very small number of iterations (less than 4). And the overhead of dispatching to a better assembly version of the loop is very significant. If we are still going to fire scalar (not unrolled) version of the loop then there is no need to prepare other versions. So I decided to disable vectorization and unrolling for `LzmaDec.c`:
```bash
$ clang -c -O3 C/LzmaDec.c ... -fno-vectorize -fno-slp-vectorize -fno-unroll-loops
```

That should remove the overhead of runtime checks inserted by the compiler for dispatching between the assembly versions for the loop. But also it reduces the code size of the outer loop (lines 153-411) in `LzmaDec_DecodeReal()`.

### Optimizations summary

Here is the summary of optimizations that could be made for this benchmark:
```
 time(s)   submission         timings for 10 consecutive runs (s)                            speedup
([5.39, 'cmov_norm_scalar', [5.39, 5.39, 5.39, 5.39, 5.39, 5.39, 5.39, 5.4,  5.41, 5.42]], ' +11.7%')
([5.42, 'cmov_norm',        [5.42, 5.43, 5.43, 5.43, 5.43, 5.43, 5.43, 5.43, 5.44, 5.45]], ' +11.0%')
([5.49, 'cmov',             [5.49, 5.49, 5.49, 5.5,  5.51, 5.51, 5.51, 5.52, 5.54, 5.54]], '  +9.7%')
([6.02, 'baseline',         [6.02, 6.02, 6.03, 6.03, 6.04, 6.05, 6.06, 6.07, 6.07, 6.08]], ' ')
```

I think it was a good and interesting challenge. Improving such a mature application as `7-zip` by 12% is very cool. However, I would not run to the author of `7-zip` with pull request from those patches, because we just improved the single workload of `7-zip`. It might be the case that for some of the workloads it would only make the things worse.

### Further optimization directions

1. I would continue reducing the code size of the outermost loop (lines 153-411) in `LzmaDec_DecodeReal()`. It should be possible to do by [outlining]({{ site.url }}/blog/2019/03/27/Machine-code-layout-optimizatoins#function-splitting) cold parts of the loop. For example, lines 209-260.
2. I did briefly look at the other hotspots. Function `GetMatchesSpec1` seems to be a good candidate for inlining. Just that `GET_MATCHES_FOOTER` generates a lot of code and looks like it's cold. Maybe it's a good idea to outline it as well.
3. [Top Down analysis]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) shows there are other small issues like DTLB misses (attribute to 1% cycles stalled) and [store-to-load forwarding]({{ site.url }}/blog/2018/03/09/Store-forwarding) failures (attribute to 0.5% cycles stalled). Also analysis shows there are Ports_Utilization problems which could be worth analyzing.

------
[^1]: At least newer versions: clang 9.0 and gcc 8.2.
[^2]: I wrote a little bit about PGO [here]({{ site.url }}/blog/2019/03/27/Machine-code-layout-optimizatoins#profile-guided-optimizations-pgo). Guide for using PGO in clang in [here](https://clang.llvm.org/docs/UsersManual.html#profiling-with-instrumentation).
[^3]: Using clang pragmas described [here](https://llvm.org/docs/Vectorizers.html#pragma-loop-hint-directives).
