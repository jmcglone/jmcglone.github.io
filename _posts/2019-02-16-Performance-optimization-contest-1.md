---
layout: post
title: Performance optimization contest &#35&#49.
tags: default
---

Recently I announced performance optimization contest in my recent [article](https://dendibakh.github.io/blog/2019/02/02/Performance-optimization-contest). If you see this post and haven't read my initial post about the [contest](https://dendibakh.github.io/blog/2019/02/02/Performance-optimization-contest), I recommend that you first read it. 

Now it's time to start our first edition. I'm glad to say "Welcome" to every participant!

#### I'm collecting all your submissions until 25th February 2019 and will announce results on 1st March 2019.

The benchmark for the contest is:
https://github.com/llvm-mirror/test-suite/blob/master/SingleSource/Benchmarks/Shootout/sieve.c

```cpp
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
#define LENGTH 170000
    int NUM = ((argc == 2) ? atoi(argv[1]) : LENGTH);
    static char flags[8192 + 1];
    long i, k;
    int count = 0;

    while (NUM--) {
	count = 0; 
	for (i=2; i <= 8192; i++) {
	    flags[i] = 1;
	}
	for (i=2; i <= 8192; i++) {
	    if (flags[i]) {
                /* remove all multiples of prime: i */
		for (k=i+i; k <= 8192; k+=i) {
		    flags[k] = 0;
		}
		count++;
	    }
	}
    }
    printf("Count: %d\n", count);
    return(0);
}
```

That's it. Yes, it's really small. I decided to pick single source benchmark for a first contest in order to offer a quick start for everybody.

### Quickstart

Because the benchmark has no external dependancies you can build it as simple as:
```
$ wget https://raw.githubusercontent.com/llvm-mirror/test-suite/master/SingleSource/Benchmarks/Shootout/sieve.c
$ gcc sieve.c -O3 -o sieve
$ time -p ./sieve
```

Target machine for this edition of the contest is Haswell CPU with 64-bit Linux.

### Couple of hints

1. Collect the baseline (use `time` or analogs).
2. Find the hotspot (use `perf record`).
3. Find performance headroom
  * Take a look at the assembly and try to guess how you can do better.
  * Run through [TMAM]() process.
4. Build the benchmark, run it and compare against baseline.

I also have a few general advises:
- Do not try to understand the whole benchmark. For some people (including me) it's crucial to understand how every peace of code works. For the purposes of optimizing it will be wasted effort. There are CPU benchmarks with thousands LOC (like [SPEC2017](http://spec.org/cpu2017/)) it's absoultely impossible to understand them in a reasonable time. What you need to familiarize yourself with are hotspots. That's it. You most likely need to understand one function/loop which is not more than 100 LOC.
- You have specific workload for which you optimize the benchmark. You don't need to optimize it for any other input/workload. The main principle behind [Data-oriented design](https://en.wikipedia.org/wiki/Data-oriented_design) is that you know the data of your application.

Information presented in llvm documentation: [Benchmarking tips](https://llvm.org/docs/Benchmarking.html) migth also be helpful.

### What's NOT allowed

1. Do not rewrite the benchmark completely or introduce major changes in algorithms.
2. Do not manually parallelize the benchmark, e.g converting it from single- to multi-threaded or offload computations to the GPU. I mean, I'm glad that you can do it and I will be happy to take a look what you did, but it's not the intent of the contest.
3. Using [PGO](https://en.wikipedia.org/wiki/Profile-guided_optimization) is allowed, however you can use it only for driving you optimizations, not for the submission. So, you can check how the benchmark gets better with PGO and understand why. And then make this optimization manually. Again, the purposes is practicing and learning.

### Validation

Your benchmark should output the same result as [reference](https://github.com/llvm-mirror/test-suite/blob/master/SingleSource/Benchmarks/Shootout/sieve.reference_output):
```
Count: 1028
```

### Submissions

> __Disclaimer__: Again I think it's worth to say that I will not use your submissions in any commercial purposes.

If you're willing to submit your work please __subscribe to my mailing list__ and then send all you have via email.
Rules and guidelines for submissions I described earlier in my [initial post](https://dendibakh.github.io/blog/2019/02/02/Performance-optimization-contest) in "*Q6: How should the submission look like?*".

#### I'm collecting all your submissions until 25th February 2019 and will announce results on 1st March 2019.

Good luck and have fun!

__P.S.__ I have no automation for my contest yet, so if anyone knows any good service or a way to automate it using web interface, please let me know.

__P.P.S.__ I'm also open to your comments and suggestions. If you have any suggestions for the benchmarks for the next edition of contest, please tell me.

