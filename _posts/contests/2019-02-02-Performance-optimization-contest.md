---
layout: post
title: How good of a performance optimizer you are? Contest!
categories: [contest]
---

**Contents:**
* TOC
{:toc}

### About this contest

Hello everybody!

I decided to try new thing at the beginning of 2019. You probably heard about competitive programming and about popular web-sites like [Topcoder](https://www.topcoder.com/), [Codility](https://www.codility.com/) and others. The idea is that you can try yourself in solving programming puzzles. Usually it's not enough to just solve the puzzle, your solution must qualify for certain criterias such as algorithmic complexity and memory usage. Also on a real challenges it is improtant how fast you solved the problem.

Those sort of challenges usually test your problem solving skills as well as your knowledge of algorithms and data structures. It is a kind of tasks we usually see on programming job interviews. You need to write the code from scratch to a complete solution. 

What I am starting is also a form of contest but aims at developing different set of skills. **We will train to optimize already optimized code**. We will learn hardware optimizations. This is briefly how it will look like: I will pick one existing benchmark of my choice and will send it to all my subscribers. You will have the time to play with the benchmark and find all performance headrooms you can find. You then send all your findings to me (modified sources/assemblies/compiler patches?/whatever speeds up the benchmark) and I check it and run on my hardware. At the end I will anounce the winners.

Before I explain it in more details I feel a need of writing disclaimer:

> __Disclaimer__: This is absolutely non-profit effort. I'm not looking for make any money from it or using someone's knowledge in my own purposes. I will not use submissions to extract any intellectual property they might have. Also this is not aiming to advertise any particular software product including benchmarks/compilers. That's why all the benchmarks and compilers I will use require to be open sourced. Neither it aims to advertise any particular HW.

In this contest I try to emulate the situation in performance critical projects on the final stages. When all the functionality is delivered and tested. But before shipping the binary to the customers you were asked to tune the app to it's peak performance. You know the hardware it will be deployed to. You have the sources in your hands and freedom to modify it (without introducing any bugs :) ). You are the build master, so you can add any compiler flags you want. 

For the challenges that I will send I'm not looking for optimizations that fall into the category: "Oh, I just used quicksort instead of bubblesort". Expect the benchmark to be already optimized to some degree. Your task is to tune it for particular hardware to the peak performance.

### Q&A

#### Q0: *Why ~~the hell~~ on earth I should participate in this contest?*

**A0**: You will learn/practice how to do optimizations for HW. This might include eliminating cache misses by inserting prefetch instructions, getting rid of [Code alignment issues]({{ site.url }}/blog/2018/01/18/Code_alignment_issues), improving performance by helping compiler to vectorize/unroll the loop better. You will learn different techniques as you go.

------
#### Q1: *What benchmarks are taken into the contest?*

**A1**: It will be open sourced benchmark written in C/C++. Usually several source files. It should be easy to build, require minimal dependencies. Preferably it should have some form of validation.

------
#### Q2: *What is the machine/environment we will be optimizing for?*

**A2**: Most likely it will be 64 bit Linux with Intel x86 CPU (probably Haswell architecture). For a start I will not bother with disabling CPU [dynamic frequency scaling](https://en.wikipedia.org/wiki/Dynamic_frequency_scaling) features or setting [thread affinity](https://en.wikipedia.org/wiki/Processor_affinity). I might do this in future.

------
#### Q3: *What if I don't have the environment you are using?*

**A3**: It doesn't matter much. If you don't have Intel CPU or you are on Windows/Mac, just optimize for whatever you have. I would be happy to know about optimizations that help other CPUs, operating systems, etc.
**I don't have real prizes to give, so it's mostly practicing and learning**.

------
#### Q4: *How I should find performance headrooms?*

**A4**: Use all of your knowledge. Start with profiling the benchmark. You can browse through posts on this blog. Additionally I will write a separate post that might help begginers.

------
#### Q5: *What optimizations are allowed?*

**A5**: Good news! **All the dirty tricks allowed**! The goal of this contest is to learn how to squeeze as much performance as possible from the hardware using any means available. You can modify sources and insert any compiler hints like pragmas, builtins, function attributes, etc. Also you can generate assembly listing (`-S` compiler option) and modify it. Finally, you can add some compiler option that might speed up the benchmark.

------
#### Q6: *What's NOT allowed*

**A6**: 1) Do not rewrite the benchmark completely or introduce major changes in algorithms. The good judging rule is "everything interesting should be calculated in runtime".

2) Do not manually parallelize the benchmark, e.g converting it from single- to multi-threaded or offload computations to the GPU. I mean, I'm glad that you can do it and I will be happy to take a look what you did, but it's not the intent of the contest.

3) Using [PGO](https://en.wikipedia.org/wiki/Profile-guided_optimization) is allowed, however you can use it only for driving you optimizations, not for the submission. So, you can check how the benchmark gets better with PGO and understand why. And then make this optimization manually. Again, the purposes is practicing and learning.

------
#### Q7: *How should the submission look like?*

**A7**: 1) I will not accept binaries for security reasons.

2) You can send patch files that I can apply to the sources of the benchmark or just assembly listing. If you did multiple optimizations please split them in separate patches. `git format-patch` is the right tool for that. This will save me a lot of time.

3) If you send assembly listing files please do also include diff file from the baseline (what you changed in the assembly). If you provide modified assembly listings it should be genearted only with open-sourced C/C++ compilers like gcc and clang. You can of course cheat and generate assembly with some other compiler that is better for the benchmark, but I will probably easily detect that. And it's not about tricking, it's about learning.

4) Make sure you specify clearly the compiler options if they are different from the baseline.

5) If you are capable of hacking compiler that's also acceptable. You can send me patches for gcc/llvm compilers which I can apply and use for building the benchmark. Please use the top of tree revisions because it will be easier for me to apply them. We can then use it for improving our open source compilers. Also it would be very nice if you can send me textual description of all the optimizations you made.

------
#### Q8: *How I will test your solutions?*

**A8**: I will take your sources, build them on my machine and run the benchmark. I will run your binary multiple times (depends on the running time) and [take the minimum](http://blog.kevmod.com/2016/06/benchmarking-minimum-vs-average/). I'm thinking about testing all the solutions on some cloud machine, but that's not settled yet. 

------
#### Q9: *How I will select the winner?*

**A9**: I will calculate your score as a ratio between execution time of the binary with your optimizations and the baseline.

------
I know there is a lot more concerns you might have. This is just a first attempt with focus on learning how to do HW optimizations. In the end I don't have real prizes to give out. :) After each contest I will share all the findings people did, so there is a big opportunity to learn from others! I know that a number of really experienced guys read this blog, so I encourage everyone to participate. Everyone is welcome!

All communication (including sending benchmarks and score submissions) will happen through emails, so **make sure to subscribe** using the form at the bottom of the page! I am planning to start first contest in the end of February 2019.

Let me know what you think about it or if you have any ideas or comments. You can also vote if you like it using the buttons below.

### How to get started?

1. Collect the baseline (use `time` or analogs).
2. Find the hotspot (use `perf record`).
3. Find performance headroom
  * Take a look at the assembly and try to guess how you can do better.
  * Run through [TMAM]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) process.
4. Build the benchmark, run it and compare against baseline.

### Hints

- Do not try to understand the whole benchmark. For some people (including me) it's crucial to understand how every peace of code works. For the purposes of optimizing it will be wasted effort. There are CPU benchmarks with thousands LOC (like [SPEC2017](http://spec.org/cpu2017/)) it's absoultely impossible to understand them in a reasonable time. What you need to familiarize yourself with are hotspots. That's it. You most likely need to understand one function/loop which is not more than 100 LOC.
- You have specific workload for which you optimize the benchmark. You don't need to optimize it for any other input/workload. The main principle behind [Data-oriented design](https://en.wikipedia.org/wiki/Data-oriented_design) is that you know the data of your application.

Information presented in llvm documentation: [Benchmarking tips](https://llvm.org/docs/Benchmarking.html) migth also be helpful.

### List of contest editions

- [Contest #1]({{ site.url }}/blog/2019/02/16/Performance-optimization-contest-1) - 16 Feb 2019.
- [Contest #2]({{ site.url }}/blog/2019/04/10/Performance-analysis-and-tuning-contest-2) - 10 Apr 2019.
- [Contest #3]({{ site.url }}/blog/2019/05/28/Performance-analysis-and-tuning-contest-3) - 28 May 2019.
