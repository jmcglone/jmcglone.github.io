---
layout: post
title: Performance optimization contest &#35&#49.
categories: [contest]
---

**Contents:**
* TOC
{:toc}

Recently I announced performance optimization contest in my recent [article]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest). If you see this post and haven't read my initial post about the [contest]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest), I recommend that you first read it. 

Now it's time to start our first edition. I'm glad to say "Welcome" to every participant!

**I'm collecting all your submissions until 25th February 2019 and will announce results on 1st March 2019.**

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
```bash
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
  * Run through [TMAM]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) process.
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
Rules and guidelines for submissions I described earlier in my [initial post]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest) in "*Q6: How should the submission look like?*".

**I'm collecting all your submissions until 25th February 2019 and will announce results on 1st March 2019.**

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

1. Limit loop16 (loop on the line# 16) to run until sqrt(8192) - 2.6x speedup. That requires to move counting it in a separate loop.
2. Do not mark even numbers and iterate only through the odd numbers - 2.3x speedup.

Source code with both optimizations combined can be found on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve.c).

And of course there was a [submission](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve_constexpr.c) that utilized C++ constexpr feature and just printed correct answer in the runtime.

Other observations made by participants:
- converting `char flags[]` to bitfields showed negative effect.
- all the code and all the data fits into L1I and L1D caches. No prefetching opportunities.
 
### Second round

Now when all the low-hanging fruits are found it's not that easy to optimize it further. But it doesn't mean there is absolutely no performance headroom. I briefly tried to optimize the version from my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve.c) even more. By adding proper loop unrolling hints to the compiler and adjusting alignment of the loops I was able to reduce the execution time from `0.32s` down to `0.27s`. If I'll find time I'll write more about it.

If you wish you can take this as your homework. Take the the code from my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve.c) as a baseline. To make results more stable I suggest to increase the number of repetitions from `170000` to `1700000`.

Let me know what you can find.

## _Updated 7th April 2019_

I spent some time on solving the contest myself. Here is the baseline that I started with:

{% highlight cpp linenos %}
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
#define LENGTH 1700000
    int NUM = ((argc == 2) ? atoi(argv[1]) : LENGTH);
    static char flags[8192 + 1];
    long i, k;
    long sqrt_max = sqrt(8192);
    int count;

    while (NUM--) {
        for (i=2; i < 8192; i+=2) {
            flags[i] = 0;     // evens are not prime
            flags[i+1] = 1;   // odd numbers might be
        }
	// flags[8192] doesn't need to be set, because it's even

        // since even numbers already crossed out we can:
        //  - start from i=3 
        //  - iterate over odd numbers (i+=2)
	for (i=3; i <= sqrt_max; i+=2) { 
	    if (flags[i]) {
                /* remove all multiples of prime: i */
		// 1. less than i*i already marked
		// 2. only mark odd multiples (i*i+i will
		//    produce even number, which is already marked)
		for (k=i*i; k <= 8192; k+=2*i) {
		    flags[k] = 0;
		}
	    }
	}
        count = 1; // accounting for 2 is prime
        for (long i = 2; i <= 8192; i++) {
            if (flags[i])
                count++;
        }
    }
    printf("Count: %d\n", count);
    return(0);
}
{% endhighlight %}

Here is what we can be done:

**1)** User on my mailing list Nan Xiao suggested that since only odd number can be prime, there is no need to initialize even number (line 14). Additionally there is no need to check even number when counting. Full version can be found [here](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/1/sieve_no_evens.c). Interestingly that has negative effect of 20% performance drop. But the reason for that is that now it's harder for compiler to vectorize the memset (line 13) and counting (line 34) loops since it can't touch even locations.

**2)** I profiled the baseline and found that we have 2 hotspots in the benchmark. 

First is the loop where we mark odd multiples (line 28). Second is the counting loop (line 34).

I also applied [Top-Down Analysis]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) on it and found that we are 80% bound by Retirement, which means we already are doing quite good. 

Let's look at the first hotspot:
```cpp
for (k=i*i; k <= 8192; k+=2*i) {
  flags[k] = 0;
}
```
Here is the assembly generated by gcc 7.4:
```asm
.loop:
mov BYTE PTR [rax+0x601080], 0x0
add rax,rcx
cmp rax,0x2000
jle .loop
```
In this loop `rax` corresponds to `k` and `rcx` corresponds to `2*i`.

**3)** First idea I tried was unrolling this loop using compiler hint. For that to work I bumped GCC version to 8.2.
```cpp
#pragma GCC unroll 2
for (k=i*i; k <= 8192; k+=2*i) {
  flags[k] = 0;
}
```
Unrolling this loop gave negative effects for all the factors I tried: 2,4,8,16,32. We didn't increase the amount of instructions executed on each iteration since we need to check if we are inbounds for every write. But unrolling the loop reulted in code bloat which is bad for CPU front-end.

**4)** I decided to check if this is the best what we can do in the first hotspot. I applied the technique I showed [here]({{ site.url }}/blog/2019/04/03/Precise-timing-of-machine-code-with-Linux-perf) (yes, I did that part on Skylake). And found that 99% of the time each iteration of the loop runs in one cycle. This loop is bound by stores and since we have one execution port for doing stores on Haswell and Skylake, we can't do better than that.

There is another (not accurate) way to prove this. It is very simple, but you've better not use it on any kernels that are more complicated than the one in this contest. So, first I got the total number of cycles:
```bash
$ perf stat ./sieve
       16299730506      cycles                    #    3,784 GHz 
```
We have `1700000` repetitions of the outermost loop. Dividing total number of cycles by the number of repetitions we get roughly `10000` cycles per repetition. Knowing that we have 50% of the time spent in this loop we can say that we have `5000` for this loop. After that I manually instrumented the code to count the trip count (number of iterations) of the loop where we mark the odd multiples. It turned out that we have `4823` iterations in total. Dividing number of cycles for the loop by the number of iterations of the loop we get ~1 cycle per iteration. This is very inaccurate way, but it works for small kernels.

**5)** I tried [aligning]({{ site.url }}/blog/2018/01/18/Code_alignment_issues) different loops at different boundaries (16 bytes, 32, 64, 128) but that yielded negative effect in all the cases. The reason for this is that NOPs are injected in the execution path.

**6)** I looked at the other hotspot which was the counting loop:
```cpp
for (long i = 2; i <= 8192; i++) {
  if (flags[i])
    count++;
}
```

This code was vectorized, which is good. But it was done using XMM vectors, which is not optimal. I tried to use AVX instructions:
```
gcc sieve.c -O3 -march=core-avx2 -o sieve
```

That gave 20% speedup.

**7)** I profiled improved version again and now we can see three hot places:
1. marking loop (line 28) ~70%
2. counting loop (line 34) ~25%
3. memset loop (line 13) ~5%

I also tried unrolling the first loop, but it didn't make any improvement.

Running TMAM on improved version showed this result:
```bash
$ ~/pmu-tools/toplev.py --core S0-C0 -l1 -v --no-desc taskset -c 0 ./sieve
S0-C0    FE             Frontend_Bound:           7.38 +-     0.00 % Slots below
S0-C0    BAD            Bad_Speculation:          5.76 +-     0.00 % Slots below
S0-C0    BE             Backend_Bound:           24.80 +-     0.00 % Slots       <==
S0-C0    RET            Retiring:                62.06 +-     0.00 % Slots below

$ ~/pmu-tools/toplev.py --core S0-C0 --nodes Memory_Bound,Core_Bound -v --no-desc taskset -c 0 ./sieve
S0-C0    BE/Mem         Backend_Bound.Memory_Bound:          1.91 +-     0.00 % Slots below
S0-C0    BE/Core        Backend_Bound.Core_Bound:           22.85 +-     0.00 % Slots       <==

$ ~/pmu-tools/toplev.py --core S0-C0 --nodes Divider,Ports_Utilization -v --no-desc taskset -c 0 ./sieve
S0-C0-T0 BE/Core        Backend_Bound.Core_Bound.Divider:                    0.00 +-     0.00 % Clocks below
S0-C0-T0 BE/Core        Backend_Bound.Core_Bound.Ports_Utilization:         24.43 +-     0.00 % Clocks below <==
```

Most likely that points us to the problem we analyzed before, which is marking loop (line 28) is bound by the stores.

### Total score table of all my attempts

```
 time(s)  submission    timings for 10 consecutive runs (s)                              speedup
([3.56,   'AVX2',       [3.56, 3.56, 3.56, 3.56, 3.56, 3.56, 3.56, 3.56, 3.56, 3.56]], ' + 1.21x')
([4.29,   'baseline',   [4.29, 4.29, 4.29, 4.29, 4.3, 4.3, 4.3, 4.3, 4.3, 4.33]],      ' + 1.0x' )
([4.35,   'align loop', [4.35, 4.35, 4.35, 4.35, 4.35, 4.35, 4.35, 4.35, 4.35, 4.35]], ' + 0.99x')
([4.4,    'unroll',     [4.4, 4.4, 4.4, 4.41, 4.41, 4.41, 4.41, 4.41, 4.41, 4.41]],    ' + 0.97x')
([5.28,   'elim_evens', [5.28, 5.28, 5.29, 5.29, 5.29, 5.29, 5.29, 5.29, 5.29, 5.29]], ' + 0.81x')
```
