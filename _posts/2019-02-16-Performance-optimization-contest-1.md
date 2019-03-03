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

{% highlight cpp linenos %}
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
{% endhighlight %}

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
  * Run through [TMAM](https://dendibakh.github.io/blog/2019/02/09/Top-Down-performance-analysis-methodology) process.
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

The baseline that I will be measuring against is 'gcc -O3'.

If you're willing to submit your work please __subscribe to my mailing list__ and then send all you have via email.
Rules and guidelines for submissions I described earlier in my [initial post](https://dendibakh.github.io/blog/2019/02/02/Performance-optimization-contest) in "*Q6: How should the submission look like?*".

#### I'm collecting all your submissions until 25th February 2019 and will announce results on 1st March 2019.

Good luck and have fun!

__P.S.__ I have no automation for my contest yet, so if anyone knows any good service or a way to automate it using web interface, please let me know.

__P.P.S.__ I'm also open to your comments and suggestions. If you have any suggestions for the benchmarks for the next edition of contest, please tell me.

---

## _Updated 2nd March 2019_

### Scores

I received 7 submissions for the contest which is quite good. I wrote the script to automate measuring process (you can find it [here](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/run.py)).

My setup: xeon E3-1240 v3 + gcc 7.4 + Red Hat 7.4.

The baseline code showed this results:
```
time(s)   submission   timings for 10 consecutive runs (s)
([2.31,   'baseline',  [2.31, 2.32, 2.32, 2.32, 2.32, 2.32, 2.32, 2.32, 2.32, 2.32]])
```

Here are the best 3 submissions:
```
   time(s)   submission         timings for 10 consecutive runs (s)                            speedup
1. ([0.34,   'Nathan Kurz'    , [0.34, 0.34, 0.34, 0.34, 0.34, 0.34, 0.34, 0.34, 0.34, 0.34]], ' + 6.79x')
2. ([0.46,   'Hector Grebbell', [0.46, 0.46, 0.46, 0.46, 0.46, 0.46, 0.46, 0.46, 0.47, 0.47]], ' + 5.02x')
3. ([1.06,   'Hadi Brais'     , [1.06, 1.07, 1.07, 1.07, 1.07, 1.07, 1.07, 1.07, 1.07, 1.07]], ' + 2.18x')
```
Congratulations!

### Optimizations found

There were some amount of complaints about the benchmark and I admit it has high-level inefficiencies. So most of the optimizations I will present have algoritmic nature and are not necessary related to CPU microarchitecture. Indeed, it is not smart to look for low-level optimizations when there are high-level ones. However, bear with me, I do have something to offer.

Because things that I will present can be easily found on the web, I will not explain it in very details. Yo can read more about Sieve of Eratosthenes on the [wikipedia](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes).

1. Limit loop16 (loop on the line# 16) to run until sqrt(8192) - 2.6x speedup.
2. Do not mark even numbers and iterate only through the odd numbers - 2.3x speedup.
3. Move counting out of the outtermost loop (i.e. put it in a separate loop) - no speedup.

All optimizations combined can be found on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve.c).

And of course there was a [submission](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve_constexpr.c) that utilized C++ constexpr feature and just printed correct answer in the runtime.

Other observations made by participants:
- converting `char flags[]` to bitfields showed negative effect.
- all the code and all the data fits into L1I and L1D caches. No prefetching opportunities.
 
### Second round

Now when all the low-hanging fruits are found it's not that easy to optimize it further. But it doesn't mean there is absolutely no performance headroom. I briefly tried to optimize the version from my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve.c) even more. By adding proper loop unrolling hints to the compiler and adjusting alignment of the loops I was able to reduce the execution time from `0.32s` down to `0.27s`. 

If you wish you can take this as your homework. Take the the code from my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve.c) as a baseline. To make results more stable I suggest to increase the number of repetitions from `170000` to `1700000`.

Let me know what you can find.

