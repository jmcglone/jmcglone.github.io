---
layout: post
title: Tools for microarchitectural benchmarking.
tags: default
---

I did a fair amount of low level experiments during the recent months and I tried different tools for making such experiments. In this post I just want to bring everything that I know in one common place.

**Disclaimer: I don't want to compare different tools.**

### What do I mean by microarchitectural benchmarking?

Modern computers are so complicated that it's really hard to measure something in isolation. It's not enough to just run your benchmark and measure execution time. You need to think about context switches, CPU frequency scaling features (called "turboboost"), etc. There are a lot of details that can affect execution time.

What would you do if you want just to benchmark two assembly sequences? Or you want to experiment with some HW feature to see how it works?

Even if my benchmark is a simple loop inside `main` and I measure execution time of the whole binary - that's not a benchmark that I want. There is a lot of code that runs before main, so it will add a lot of noise. Also if I will collect performance counters with `perf stat -e` it will add a lot of noise in the results. 

What I want is to have a fine-grained analysis for some specific code region, not the whole execution time. Microarchitectural benchmarking without collecting performance counters is a must, so I want to have that as well. For describing such kind of experiments I came up with a term "microarchitectural benchmarking" and it maybe not very accurate, so I'm open for suggestions/comments here.

In this post I will quickly give you a taste of the tools available without going to much into the details. Also we need to distinguish between static and dynamic tools.

Static tools don't run the actual code but try to simulate the execution keeping as much microarchitectural details as they can. Of course they are not capable of doing real measurements (execution time, performance counters) because they don't run the code. The good thing about that is that you don't need to have the real HW. You don't need to have privileged access rights as well. Another benefit is that you don't need to worry about consistency of the results. They will be always consistent because execution is not biased in any way. The downside of static tools is that usually they can't predict and simulate everything inside modern CPUs. Today we will look into two examples of such tools: [IACA](https://software.intel.com/en-us/articles/intel-architecture-code-analyzer) and [llvm-mca](https://llvm.org/docs/CommandGuide/llvm-mca.html).

Dynamic tools are based on running the code on the real HW and collecting all sorts of information about the execution. The good thing about it is that this is the only 100% reliable method of proving things. However, it's not so easy to write a good benchmark and measure what you want to measure. Also you need to fight with the noise and different kinds of side effects. We will take a look at [uarch-bench]() and [likwid]().

### Benchmark kernel

Microarchitectural benchmarking is often used when you want to stress some particular CPU feature or find the bottleneck in some small piece of code. I decided to come up with an assembly example that wouyld be handled equally good by all the tools.

I will try to run the same experiment under each of those tools and show the output. I will try to stress my IvyBridge CPU with example from my previous article about [port contention](https://dendibakh.github.io/blog/2018/03/21/port-contention). 

```asm
mov eax, DWORD [rsp]     ; goes to port 2 or 3
mov eax, DWORD [rsp + 4] ; port 2 or 3
bswap ebx		 ; goes to port 1
bswap ecx		 ; goes to port 1 (port contention)
```

### IACA

[IACA](https://software.intel.com/en-us/articles/intel-architecture-code-analyzer) stands for Intel® Architecture Code Analyzer. IACA helps you statically analyze the data dependency, throughput and latency of code snippets on Intel® microarchitectures.

It has API for C, C++ and assembly languages. In order to use it you just need to wrap the code that you want to analyze with special markers and you're done. Then you need to run your binary under IACA and it will analyze the region of the code that you specified.

In order to use it you need to compile your binary with special markers inserted before and after the region that you want to analyze.

```
mov ebx, 111 		; Start marker bytes
db 0x64, 0x67, 0x90 	; Start marker bytes

	; kernel

mov ebx, 222 		; End marker bytes
db 0x64, 0x67, 0x90 	; End marker bytes
```

Complete code can be found on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/Tools_for_microarchitectural_benchmarking/iaca/port_contention.asm).

Then we run the binary under IACA. 

```
./iaca -arch HSW -trace iaca.log -trace-cycle-count 50 ./a.out
```

Unfortunately, in latest version (3.0) support for IVB was dropped, and previos version (2.3) showed some really wierd results, so I decided to simulate it on HSW. Here is the output that it produces:
```
Intel(R) Architecture Code Analyzer Version -  v3.0-28-g1ba2cbb build date: 2017-10-23;16:42:45
Analyzed File -  ./a.out
Binary Format - 64Bit
Architecture  -  HSW
Analysis Type - Throughput

Throughput Analysis Report
--------------------------
Block Throughput: 1.79 Cycles       Throughput Bottleneck: FrontEnd
Loop Count:  31
Port Binding In Cycles Per Iteration:
--------------------------------------------------------------------------------------------------
|  Port  |   0   -  DV   |   1   |   2   -  D    |   3   -  D    |   4   |   5   |   6   |   7   |
--------------------------------------------------------------------------------------------------
| Cycles |  1.0     0.0  |  1.0  |  1.0     1.0  |  1.0     1.0  |  0.0  |  1.0  |  1.0  |  0.0  |
--------------------------------------------------------------------------------------------------

DV - Divider pipe (on port 0)
D - Data fetch pipe (on ports 2 and 3)
F - Macro Fusion with the previous instruction occurred
* - instruction micro-ops not bound to a port
^ - Micro Fusion occurred
# - ESP Tracking sync uop was issued
@ - SSE instruction followed an AVX256/AVX512 instruction, dozens of cycles penalty is expected
X - instruction not supported, was not accounted in Analysis

| Num Of   |                    Ports pressure in cycles                         |      |
|  Uops    |  0  - DV    |  1   |  2  -  D    |  3  -  D    |  4   |  5   |  6   |  7   |
-----------------------------------------------------------------------------------------
|   1      |             |      | 1.0     1.0 |             |      |      |      |      | mov eax, dword ptr [rsp]
|   1      |             |      |             | 1.0     1.0 |      |      |      |      | mov eax, dword ptr [rsp+0x4]
|   2      |             | 1.0  |             |             |      |      | 1.0  |      | bswap ebx
|   2      | 1.0         |      |             |             |      | 1.0  |      |      | bswap ecx
|   1*     |             |      |             |             |      |      |      |      | dec rdi
|   0*F    |             |      |             |             |      |      |      |      | jnz 0xfffffffffffffff2
Total Num Of Uops: 7
```

IACA helps in finding bottlenecks of a loop body:
- It provides throughput of the whole analyzed block (counted in cycles).
- It predicts what would be the bottleneck source that will limit the throughput.
- It tells what ports are under the biggest pressure.

More detailed description of the output can be found in the [IACA Users Guide](https://software.intel.com/sites/default/files/m/d/4/1/d/8/Intel_Architecture_Code_Analyzer_2.0_Users_Guide.pdf).

But the most interesting part is in the pipeline traces (generated by `-trace` option):
```
it|in|Dissasembly                                       :01234567890123456789012345678901234567890123456789
 0| 0|mov eax, dword ptr [rsp]                          :          |         |         |         |         
 0| 0|    TYPE_LOAD (1 uops)                            :s---deeeew----R-------p       |         |         
 0| 1|mov eax, dword ptr [rsp+0x4]                      :          |         |         |         |         
 0| 1|    TYPE_LOAD (1 uops)                            :s---deeeew----R-------p       |         |         
 0| 2|bswap ebx                                         :          |         |         |         |         
 0| 2|    TYPE_OP (2 uops)                              :sdew----------R-------p       |         |         
 0| 3|bswap ecx                                         :          |         |         |         |         
 0| 3|    TYPE_OP (2 uops)                              : sdew----------R-------p      |         |         
 0| 4|dec rdi                                           :          |         |         |         |         
 0| 4|    TYPE_OP (1 uops)                              : sdw-----------R-------p      |         |         
 0| 5|jnz 0xfffffffffffffff2                            :          |         |         |         |         
 0| 5|    TYPE_OP (0 uops)                              : w-------------R-------p      |         |         
 1| 0|mov eax, dword ptr [rsp]                          :          |         |         |         |         
 1| 0|    TYPE_LOAD (1 uops)                            : s---deeeew----R-------p      |         |         
 1| 1|mov eax, dword ptr [rsp+0x4]                      :          |         |         |         |         
 1| 1|    TYPE_LOAD (1 uops)                            :  s---deeeew----R-------p     |         |         
 1| 2|bswap ebx                                         :          |         |         |         |         
 1| 2|    TYPE_OP (2 uops)                              :  sdew----------R-------p     |         |         
 1| 3|bswap ecx                                         :          |         |         |         |         
 1| 3|    TYPE_OP (2 uops)                              :  Asdew---------R-------p     |         |         
 1| 4|dec rdi                                           :          |         |         |         |         
 1| 4|    TYPE_OP (1 uops)                              :   w-------------R-------p    |         |         
 1| 5|jnz 0xfffffffffffffff2                            :          |         |         |         |         
 1| 5|    TYPE_OP (0 uops)                              :   w-------------R-------p    |         |
```

Complete output of it can be found on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/Tools_for_microarchitectural_benchmarking/iaca/iaca.log).

I haven't found any complete information about limitations of that tool, but I tried to run binaries with inserted markers from my [Code Alignment](https://dendibakh.github.io/blog/2018/01/18/Code_alignment_issues) post and IACA showed no difference. But I know that there is significant performance difference between them.

### llvm-mca

[llvm-mca](https://llvm.org/docs/CommandGuide/llvm-mca.html) is a LLVM Machine Code Analyzer tool which is also a static analyzer. From it's description:
> llvm-mca is a performance analysis tool that uses information available in LLVM (e.g. scheduling models) to statically measure the performance of machine code in a specific CPU<Paste>

It was fairly recently [announced on llvm-dev mailing list](https://groups.google.com/forum/#!msg/llvm-dev/QwoBh1EXv60/F57decl9AwAJ;context-place=forum/llvm-dev) and checked into llvm trunk. So, documentation for it is yet not mature enough, so the best source of information for now is this email thread on llvm-dev mailing list that I mentioned earlier.

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
> The tool only models the out-of-order portion of a processor. Therefore, the instruction fetch and decode stages are not modeled. Performance bottlenecks in the frontend are not diagnosed by this tool. The tool assumes that instructions have all been decoded and placed in a queue. Also, the tool doesn't know anything about branch prediction and simultaneous mutithreading.
>
> Also the tool has very relaxed model for LSUnit (load and store unit). It doesn't know when store-to-load forwarding may occur and doesn't attempt to predict whether a load or store hits or misses the L1 cache.

### uarch-bench

### likwid

Run experiment on IVB
