---
layout: post
title: Performance analysis and tuning contest &#35&#50.
tags: default
---

**Contents:**
* TOC
{:toc}

Welcome to the second edition of my performance analysis and tuning contest. If you see this post and haven't read my initial post about the [contest]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest), I encourage you to read it first. 

------
**Subscribe to my [mailing list](https://dendibakh.github.io/blog/2019/04/10/Performance-analysis-and-tuning-contest-2#mc_embed_signup) to participate!**

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

Target machine for this edition of the contest is again Haswell CPU with 64-bit Linux. Although you can do your experiments on Windows since `cmake` is used for building the benchmark. If you choose Windows as a platform, here is the article that might be helpful: [How to collect CPU performance counters on Windows?](https://dendibakh.github.io/blog/2019/02/23/How-to-collect-performance-counters-on-Windows).

### Couple of hints

Here is the workflow that I recommend: 

1. Collect the baseline (use `time` or analogs).
2. Find the hotspot (use `perf record`).
3. Find performance headroom
  * Take a look at the assembly and try to guess how you can do better.
  * Collect general statistics like branch mispredictions, cache-misses (use `perf stat`).
  * Run through [TMAM](https://dendibakh.github.io/blog/2019/02/09/Top-Down-performance-analysis-methodology) process.
4. Fix the issue, build the benchmark, run it and compare against baseline.

I also have a few general advises:
- **Do not try to understand the whole benchmark**. For some people (including me) it's crucial to understand how every peace of code works. For the purposes of optimizing it will be wasted effort. There are CPU benchmarks with thousands LOC (like [SPEC2017](http://spec.org/cpu2017/)) it's absolutely impossible to understand them in a reasonable time. What you need to familiarize yourself with are hotspots. That's it. You most likely need to understand one function/loop which is not more than 100 LOC.
- **You have specific workload for which you optimize the benchmark**. You don't need to optimize it for any other input/workload. The main principle behind [Data-oriented design](https://en.wikipedia.org/wiki/Data-oriented_design) is that you know the data of your application.

If you feel you're stuck, don't hesitate to ask questions or look for support elsewhere. I don't have much time to answer every question promptly, but I will do my best.

__See the Q&A post about what optimizations are [allowed](https://dendibakh.github.io/blog/2019/02/02/Performance-optimization-contest#q5-what-optimizations-are-allowed) and what [not](https://dendibakh.github.io/blog/2019/02/02/Performance-optimization-contest#q6-whats-not-allowed).__

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

If you're willing to submit your work __subscribe to my [mailing list](https://dendibakh.github.io/blog/2019/04/10/Performance-analysis-and-tuning-contest-2#mc_embed_signup)__ and then send all that you have via email.

__See the rules and guidelines for submissions [here](https://dendibakh.github.io/blog/2019/02/02/Performance-optimization-contest#q7-how-should-the-submission-look-like).__

If you are in a position of writing article with description of your findings, I highly encourage you to do so. It will be much better to have the author describe the finding in comparison with me interpreting your submission. 

**I'm collecting all your submissions until 30th April 2019.**

### Spread the word

If you know someone who might be interesting in participating in this contest, please spread the word about it!

Good luck and have fun!

__P.S.__ I have no automation for my contest yet, so if anyone knows any good service or a way to automate it using web interface, please let me know.

__P.P.S.__ I'm also open to your comments and suggestions. If you have an proposition of a benchmark for the next edition of the contest, please tell me about it.

------
[^1]: At least newer versions: clang 9.0 and gcc 8.2.
