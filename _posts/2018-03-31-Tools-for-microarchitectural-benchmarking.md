---
layout: post
title: Tools for microarchitectural benchmarking.
tags: default
---

I did a fair amount of low level experiments during the recent months and I tried different tools for making such experiments.

*Disclaimer:*
In this post I just want to bring everything that I know in one common place. **I don't want to compare different tools.**

### What do I mean by microarchitectural benchmarking?

Modern computers are so complicated that it's really hard to measure something in isolation. It's not enough to just run your benchmark and measure execution time. You need to think about context switches, CPU frequency scaling features (called "turboboost"), etc. There are a lot of details that can affect execution time.

What would you do if you want just to benchmark two assembly sequences? Or you want to experiment with some HW feature to see how it works?

Even if my benchmark is a simple loop inside `main` and I measure execution time of the whole binary - that's not a benchmark that I want because there is a lot of code that runs before main - it will add a lot of noise. Also if I will collect performance counters with `perf stat -e` it will add a lot of noise in the results. What I want is fine-grained performance counters collection for some specified region, not the whole execution time.

In this post I will quickly give you a taste of the tools available without going to much into the details. Also we need to distinguish between static and dynamic tools. 

Static tools don't run the actual code but try to simulate the execution keeping as much microarchitectural details as they can. Of course they are not capable of doing real measurements (execution time, performance counters) because they don't run the code. The good thing about that is that you don't need to have the real HW. You don't need to have privileged access rights as well. Another benefit is that you don't need to worry about consistency of the results. They will be always consistent because execution is not biased in any way. Today we will look into two examples of such tools: [IACA](https://software.intel.com/en-us/articles/intel-architecture-code-analyzer) and [llvm-mca]().

Dynamic tools are based on running the code on the real HW and collecting all sorts of information about the execution. The good thing about it is that this is the only 100% reliable method of proving things. Usually static tools still can't predict and simulate everything inside modern CPUs. We will take a look at [uarch-bench]() and [likwid]().

### Benchmark kernel

I will try to run the same experiment under each of those tools and see the output. I will use the simple example of failed [load-to-store forwarding](https://dendibakh.github.io/blog/2018/03/09/Store-forwarding):

```asm
mov WORD [esi], di   ; small write
mov eax, DWORD [esi] ; big read (stall)
```

### IACA

[IACA](https://software.intel.com/en-us/articles/intel-architecture-code-analyzer) stands for Intel® Architecture Code Analyzer. IACA helps you statically analyze the data dependency, throughput and latency of code snippets on Intel® microarchitectures.

It has API for C, C++ and assembly languages. In order to use it you just need to wrap the code that you want to analyze with special markers and you're done. Then you need to run your binary under IACA and it will analyze the region of the code that you specified.

In order to use it you need to compile your binary with special markers inserted before and after the region that you want to analyze. Then run the binary under IACA:

```
example
```

Complete code can be found on my [github]().

Here is the limited output that it produces:

Complete output of it can be found [here]().

### llvm-mca

[llvm-mca](https://llvm.org/docs/CommandGuide/llvm-mca.html) is a LLVM Machine Code Analyzer tool which is also a static analyzer. From it's description:
> llvm-mca is a performance analysis tool that uses information available in LLVM (e.g. scheduling models) to statically measure the performance of machine code in a specific CPU<Paste>

It was fairly recently [announced on llvm-dev mailing list] and checked into llvm trunk. So, documentation for it is yet not mature enough, so the best source of information for now is this email thread on llvm-dev mailing list that I mentioned earlier.

Here is how to use it:

```
$ cat a.asm
movw %di, (%esi)
movl (%esi), %eax
$ llvm-mca -march=x86-64 -mcpu=ivybridge -output-asm-variant=1 -timeline ./a.asm -o mca.out
```

What this tool needs is just assembly code, you don't need to compile it. However, it accepts only AT&T assembly syntax which is sad but there are assembly converters out there. Another thing is that options are a little bit misleading and I spent some time digging into the sources to understand what I should put into them. Usually `-march` identifies the CPU architecture, but OK...

Example

This tool is really fresh but it is very limited now. From this email thread:
> The tool only models the out-of-order portion of a processor. Therefore, the instruction fetch and decode stages are not modeled. Performance bottlenecks in the frontend are not diagnosed by this tool.  The tool assumes that instructions have all been decoded and placed in a queue. Also, the tool doesn't know anything about branch prediction and simultaneous mutithreading.
>
> Also the tool has very relaxed model for LSUnit (load and store unit). It doesn't know when store-to-load forwarding may occur and doesn't attempt to predict whether a load or store hits or misses the L1 cache.

### uarch-bench



### likwid

Run experiment on IVB
