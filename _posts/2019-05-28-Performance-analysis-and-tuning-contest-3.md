---
layout: post
title: Performance analysis and tuning contest &#35&#51.
categories: contest
---

**Contents:**
* TOC
{:toc}

Welcome to the 3rd edition of my performance analysis and tuning contest. If you see this post and haven't read my initial post about the [contest]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest), I encourage you to read it first. 

------
**Subscribe to my [mailing list]({{ page.url }}#mc_embed_signup) to participate!**

------

The benchmark for the 3rd edition is lua interpreter from [LLVM test-suite](https://github.com/llvm-mirror/test-suite).

Lua is a powerful, light-weight programming language designed for extending applications. Lua is also frequently used as a general-purpose, stand-alone language. Lua is free software. For complete information, visit [Lua's web site](http://www.lua.org/).

The benchmark consists of running multiple lua scripts:
```
   bisect.lua           bisection method for solving non-linear equations
   cf.lua               temperature conversion table (celsius to farenheit)
   echo.lua             echo command line arguments
   env.lua              environment variables as automatic global variables
   factorial.lua        factorial without recursion
   fib.lua              fibonacci function with cache
   fibfor.lua           fibonacci numbers with coroutines and generators
   globals.lua          report global variable usage
   hello.lua            the first program in every language
   life.lua             Conway's Game of Life
   luac.lua             bare-bones luac
   printf.lua           an implementation of printf
   readonly.lua         make global variables readonly
   sieve.lua            the sieve of of Eratosthenes programmed with coroutines
   sort.lua             two implementations of a sort function
   table.lua            make table, grouping all data for the same item
   trace-calls.lua      trace calls
   trace-globals.lua    trace assigments to global variables
   xd.lua               hex dump
```

The faster we finish running all the scripts the better. Test harness saves the output from every lua script and takes the hash of it. Then we compare it with the reference and validate that it's the same.

### Quickstart

To download and build the benchmark do the following:
```bash
$ git clone https://github.com/llvm-mirror/test-suite
$ mkdir build
$ cd build
$ cmake -DTEST_SUITE_COLLECT_CODE_SIZE=OFF -DTEST_SUITE_BENCHMARKING_ONLY=ON -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_C_FLAGS="-O3 -march=core-avx2 -flto" -DCMAKE_CXX_FLAGS="-O3 -march=core-avx2 -flto" ../test-suite/
$ make lua -j6
```

To run the benchmark, first copy `lua.test_run.script` and `lua.test_verify.script` from my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/3) and put them into `MultiSource/Benchmarks/lua`:
```bash
$ cd MultiSource/Benchmarks/lua
$ mkdir Output
$ time -p ./lua.test_run.script
```

You may also find useful my python [script](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/3/run.py) for conducting multiple experiments. See decription inside it.

GCC compiler is a little bit ahead [^1] of Clang on this benchmark, so it will be our baseline.

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
5. Repeat steps 2-5.

I also have a few general advises:
- **Do not try to understand the whole benchmark**. For some people (including me) it's crucial to understand how every peace of code works. For the purposes of optimizing it will be wasted effort. There are CPU benchmarks with thousands LOC (like [SPEC2017](http://spec.org/cpu2017/)) it's absolutely impossible to understand them in a reasonable time. What you need to familiarize yourself with are hotspots. That's it. You most likely need to understand one function/loop which is not more than 100 LOC.
- **You have specific workload for which you optimize the benchmark**. You don't need to optimize it for any other input/workload. The main principle behind [Data-oriented design](https://en.wikipedia.org/wiki/Data-oriented_design) is that you know the data of your application.

If you feel you're stuck, don't hesitate to ask questions or look for support elsewhere. I don't have much time to answer every question promptly, but I will do my best.

__See the Q&A post about what optimizations are [allowed]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest#q5-what-optimizations-are-allowed) and what [not]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest#q6-whats-not-allowed).__

### Validation

If the benchmark ran correctly it will print nothing. Otherwise you will see something like this:
```
fpcmp: files differ without tolerance allowance
```

### Submissions

> __Disclaimer__: I will not use submissions in any commercial purposes.

The baseline that I will be measuring against is 'gcc -O3 -march=core-avx2 -flto' ([LTO](https://en.wikipedia.org/wiki/Interprocedural_optimization) helps in this benchmark).

If you're willing to submit your work __subscribe to my [mailing list]({{ page.url }}#mc_embed_signup)__ and then send all that you have via email.

__See the rules and guidelines for submissions [here]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest#q7-how-should-the-submission-look-like).__

If you are in a position of writing article with description of your findings, I highly encourage you to do so. It will be much better to have the author describe the finding in comparison with me interpreting your submission. 

**I'm collecting all your submissions until 30th June 2019.**

### Spread the word

If you know someone who might be interesting in participating in this contest, please spread the word about it!

Good luck and have fun!

__P.S.__ I have no automation for my contest yet, so if anyone knows any good service or a way to automate it using web interface, please let me know.

__P.P.S.__ I'm also open to your comments and suggestions. If you have an proposition of a benchmark for the next edition of the contest, please tell me about it.

------
[^1]: I checked mid May 2019 versions of Clang and GCC.
