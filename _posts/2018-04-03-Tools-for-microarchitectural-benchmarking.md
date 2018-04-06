---
layout: post
title: Tools for microarchitectural benchmarking.
tags: default
---

I did a fair amount of low level experiments during the recent months and I tried different tools for making such experiments. In this post I just want to bring a qiuck summary for those tools in one place.

**Disclaimer: I have no intention to compare different tools.**

### What do I mean by microarchitectural benchmarking?

Modern computers are so complicated that it's really hard to measure something in isolation. It's not enough to just run your benchmark and measure execution time. You need to think about context switches, CPU frequency scaling features (called "turboboost"), etc. There are a lot of details that can affect execution time.

What would you do if you want just to benchmark two assembly sequences? Or you want to experiment with some HW feature to see how it works?

Even if my benchmark is a simple loop inside `main` and I measure execution time of the whole binary - that's not a benchmark that I want. There is a lot of code that runs before main, so it will add a lot of noise. So, running my binary under `perf stat -e` is not something that I want for this type of benchmarking. 

What I want is to have a fine-grained analysis for some specific code region, not the whole execution time. Microarchitectural benchmarking without collecting performance counters doen't make much sense, so I want to have that as well. For describing such kind of experiments I came up with a term "microarchitectural benchmarking" and it maybe not very accurate, so I'm open for suggestions/comments here.

In this post I will give you a taste of the tools available without going too much into the details. Also we need to distinguish between static and dynamic tools.

**Static tools** don't run the actual code but try to simulate the execution keeping as much microarchitectural details as they can. Of course they are not capable of doing real measurements (execution time, performance counters) because they don't run the code. The good thing about that is that you don't need to have the real HW. You don't need to have privileged access rights as well. Another benefit is that you don't need to worry about consistency of the results. Static tools will always give you stable output, because simulation (in comparison with execution on a real hardware) is not biased in any way. The downside of static tools is that usually they can't predict and simulate everything inside modern CPUs and thus are useless in some situations. Today we will look into two examples of such tools: [IACA](https://software.intel.com/en-us/articles/intel-architecture-code-analyzer) and [llvm-mca](https://llvm.org/docs/CommandGuide/llvm-mca.html).

**Dynamic tools** are based on running the code on the real HW and collecting all sorts of information about the execution. The good thing about it is that this is the only 100% reliable method of proving things. As a downside, usually you are required to have privileged access rights to collect performance counters. Also, it's not so easy to write a good benchmark and measure what you want to measure. Finally, you need to filter the noise and different kinds of side effects. From dynamic tools, today we will take a look at [uarch-bench](https://github.com/travisdowns/uarch-bench) and [likwid](https://github.com/RRZE-HPC/likwid).

### Benchmark kernel

Microarchitectural benchmarking is often used when you want to stress some particular CPU feature or find the bottleneck in some small piece of code. I decided to come up with an assembly example that would be handled equally good by all the tools.

I will try to run the same experiment under each of those tools and show the output. I will stress my IvyBridge CPU with example from my previous article about [port contention](https://dendibakh.github.io/blog/2018/03/21/port-contention). 

```asm
mov eax, DWORD [rsp]     ; goes to port 2 or 3
mov eax, DWORD [rsp + 4] ; port 2 or 3
bswap ebx		 ; goes to port 1
bswap ecx		 ; goes to port 1 (port contention)
```

## IACA
------

[IACA](https://software.intel.com/en-us/articles/intel-architecture-code-analyzer) stands for Intel® Architecture Code Analyzer. IACA helps you statically analyze the data dependency, throughput and latency of code snippets on Intel® microarchitectures.

#### how to use it

It has API for C, C++ and assembly languages. In order to use it you just need to wrap the code that you want to analyze with special markers. Then you need to run your binary under IACA and it will analyze the region of the code that you specified.

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

Unfortunately, in latest version (3.0) support for IVB was dropped, and previous version (2.3) showed some really wierd results, so I decided to simulate it on HSW. 

#### what is the output

Here is the output that it produces:
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
- It tells what ports are under the high pressure.

More detailed description of the output can be found in the [IACA Users Guide](https://software.intel.com/sites/default/files/managed/3d/23/intel-architecture-code-analyzer-3.0-users-guide.pdf).

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

Once again, mode detailed description of the output can be found in the [IACA Users Guide](https://software.intel.com/sites/default/files/managed/3d/23/intel-architecture-code-analyzer-3.0-users-guide.pdf). Here is the most imortant part from it:

> The kernel instructions are modeled, in order, from top to bottom while the processor’s cycles run from left to right. The ‘it’ column shows the iteration count of the entire kernel, the ‘in’ column shows the instruction count within the kernel and the ‘Disassembly’ column shows the instruction’s disassembly, along with the micro-architectural instruction fragment information.
> 
> The trace displays the micro-architectural stage of each fragment inside the processor at any given cycle from allocation to retire and even post retire. The stages and possible states are:
```
[A] – Allocated
[s] – Sources ready
[c] – Port conflict
[d] – Dispatched for execution
[e] – Execute
[w] – Writeback
[R] – Retired
[p] – Post Retire
[-] – pending
[_] – Stalled due to unavailable resources
```

I think this is really cool! It allows you to see how instructions progress through the pipeline, which is not only good for educational purposes, but also can give you a hint why your code executes not as fast as you want. Though, on HSW there is no port contention issue for this assembly code, because `bswap` can be also executed at least on 2 ports. For details, take a look at my post [Understanding CPU port contention](https://dendibakh.github.io/blog/2018/03/21/port-contention).

I showed only first two iterations, but complete output of this run can be found on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/Tools_for_microarchitectural_benchmarking/iaca/iaca.log).

#### limitations

I tried to run binaries from my [Code Alignment](https://dendibakh.github.io/blog/2018/01/18/Code_alignment_issues) post with inserted IACA markers and the tool showed no difference. Meaning that this tool doen't take into account how hot piece of code is placed in the binary. I would be good to have complete list of limitations of that tool, but I haven't found this information (would be glad if someone will provide it).

## llvm-mca
------

[llvm-mca](https://llvm.org/docs/CommandGuide/llvm-mca.html) is a LLVM Machine Code Analyzer tool which is also a tool that does static analysis of the machine code. From it's description:
> llvm-mca is a performance analysis tool that uses information available in LLVM (e.g. scheduling models) to statically measure the performance of machine code in a specific CPU.

It was fairly recently [announced on llvm-dev mailing list](https://groups.google.com/forum/#!msg/llvm-dev/QwoBh1EXv60/F57decl9AwAJ;context-place=forum/llvm-dev) (March 2018) and checked into llvm trunk. So, documentation for it is not yet mature enough, so the best source of information for now is this email thread.

#### how to use it

What this tool needs is just assembly code, you don't need to compile it. However, it accepts only AT&T assembly syntax which is sad but there are assembly converters out there. Another thing is that options are a little bit misleading and I spent some time digging into the sources to understand what I should put into them. Usually `-march` identifies the CPU architecture (like ivybridge, skylake, etc.), but OK...

```
$ cat a.asm
movl (%esp), %eax
movl 4(%esp), %eax
bswapl %ebx
bswapl %ecx
$ llvm-mca -march=x86-64 -mcpu=ivybridge -output-asm-variant=1 -timeline ./a.asm -o mca.out
```

#### what is the output

The output was mostly inspired by IACA tool, so it looks really familiar to IACA users. Here is reduced output for my assembly code:

```
Iterations:     70
Instructions:   280
Total Cycles:   144
Dispatch Width: 4
IPC:            1.94

Instruction Info:
[1]: #uOps
[2]: Latency
[3]: RThroughput
[4]: MayLoad
[5]: MayStore
[6]: HasSideEffects

[1]    [2]    [3]    [4]    [5]    [6]	Instructions:
 1      5     0.50    *               	mov	eax, dword ptr [esp]
 1      5     0.50    *               	mov	eax, dword ptr [esp + 4]
 2      2     1.00                    	bswap	ebx
 2      2     1.00                    	bswap	ecx

Resources:
[0] - SBDivider
[1] - SBPort0
[2] - SBPort1
[3] - SBPort4
[4] - SBPort5
[5.0] - SBPort23
[5.1] - SBPort23

Resource pressure per iteration:
[0]    [1]    [2]    [3]    [4]    [5.0]  [5.1]  
 -     1.00   2.00    -     1.00   1.00   1.00   

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5.0]  [5.1]  	Instructions:
 -      -      -      -      -     0.50   0.50   	mov	eax, dword ptr [esp]
 -      -      -      -      -     0.50   0.50   	mov	eax, dword ptr [esp + 4]
 -      -     1.00    -     1.00    -      -     	bswap	ebx
 -     1.00   1.00    -      -      -      -     	bswap	ecx

Timeline view:
     	          0123456789    
Index	0123456789          0123

[0,0]	DeeeeeER  .    .    .  .	mov	eax, dword ptr [esp]
[0,1]	DeeeeeER  .    .    .  .	mov	eax, dword ptr [esp + 4]
[0,2]	DeeE---R  .    .    .  .	bswap	ebx
[0,3]	.DeeE--R  .    .    .  .	bswap	ecx

[1,0]	.DeeeeeER .    .    .  .	mov	eax, dword ptr [esp]
[1,1]	.DeeeeeER .    .    .  .	mov	eax, dword ptr [esp + 4]
[1,2]	. DeeE--R .    .    .  .	bswap	ebx
[1,3]	. D=eeE-R .    .    .  .	bswap	ecx

... < iterations 2..8 >

[9,0]	.    .    .  DeeeeeE-R .	mov	eax, dword ptr [esp]
[9,1]	.    .    .  DeeeeeE-R .	mov	eax, dword ptr [esp + 4]
[9,2]	.    .    .   D====eeER.	bswap	ebx
[9,3]	.    .    .   D=====eeER	bswap	ecx
```

```
D : Instruction dispatched.
e : Instruction executing.
E : Instruction executed.
R : Instruction retired.
= : Instruction already dispatched, waiting to be executed.
- : Instruction executed, waiting to be retired.
```

Resource pressure view doesn't seem right, as we know that `bswap` instruction can be executed only on PORT1 on Ivy Bridge (**UPD 06.04.2018:** issue has been fixed [r329211](http://llvm.org/viewvc/llvm-project?view=revision&revision=329211)). However, reciprocal throughput is correct (equals to 1). Because throughput is correct, timeline view also seems to be correct. On later iterations (see iteration #9) we can spot that execution starts to be limited by `bswap` instructions. You can observe the same picture in my previous post [Understanding CPU port contention](https://dendibakh.github.io/blog/2018/03/21/port-contention).

Complete output of this run can be found on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/Tools_for_microarchitectural_benchmarking/mca/mca.out).

#### limitations

This tool is really fresh and has significant restrictions. From this [email thread](https://groups.google.com/forum/#!msg/llvm-dev/QwoBh1EXv60/F57decl9AwAJ;context-place=forum/llvm-dev):
> The tool only models the out-of-order portion of a processor. Therefore, the instruction fetch and decode stages are not modeled. Performance bottlenecks in the frontend are not diagnosed by this tool. The tool assumes that instructions have all been decoded and placed in a queue. Also, the tool doesn't know anything about branch prediction and simultaneous mutithreading.
>
> Also the tool has very relaxed model for LSUnit (load and store unit). It doesn't know when store-to-load forwarding may occur and doesn't attempt to predict whether a load or store hits or misses the L1 cache.

## uarch-bench
------

I made quite big amount of experiments with [uarch-bench](https://github.com/travisdowns/uarch-bench) in my recent posts, so readers of my blog might had a chance to get familiar with it already. From it's description:

> Uarch-bench is a fine-grained micro-benchmark intended to investigate micro-architectural details of a target CPU, or to precisely benchmark small functions in a repeatable manner.

#### how to use it

All the benchmarks are integrated in the main binary, so in order to write your own benchmark in assembly code you need to insert it into [x86_methods.asm](https://github.com/travisdowns/uarch-bench/blob/master/x86_methods.asm) and register it in [misc-benches.cpp](https://github.com/travisdowns/uarch-bench/blob/master/misc-benches.cpp):

```asm
GLOBAL PortContention

PortContention:

push rcx
push rbx
ALIGN 16

.loop:
mov eax, DWORD [esi] 
mov eax, DWORD [esi + 4]
bswap ebx
bswap ecx
dec edi
jnz .loop

pop rbx
pop rcx
ret
```

#### what is the output

I compiled and run it:

```
$ ./uarch-bench --test-name="PortContention" --timer=libpfc --extra-events=UOPS_DISPATCHED_PORT.PORT_1,UOPS_DISPATCHED_PORT.PORT_2,UOPS_DISPATCHED_PORT.PORT_3,UOPS_DISPATCHED_PORT.PORT_5

USE_LIBPFC=1
make: Nothing to be done for 'all'.
Welcome to uarch-bench (c75eeb8-dirty)
libpfm4 initialized successfully
Event 'UOPS_DISPATCHED_PORT.PORT_1' resolved to 'ivb::UOPS_DISPATCHED_PORT:PORT_1:k=1:u=1:e=0:i=0:c=0:t=0, short name: 'UOPS_D' with code 0x5302a1
Event 'UOPS_DISPATCHED_PORT.PORT_2' resolved to 'ivb::UOPS_DISPATCHED_PORT:PORT_2:k=1:u=1:e=0:i=0:c=0:t=0, short name: 'UOPS_D' with code 0x530ca1
Event 'UOPS_DISPATCHED_PORT.PORT_3' resolved to 'ivb::UOPS_DISPATCHED_PORT:PORT_3:k=1:u=1:e=0:i=0:c=0:t=0, short name: 'UOPS_D' with code 0x5330a1
Event 'UOPS_DISPATCHED_PORT.PORT_5' resolved to 'ivb::UOPS_DISPATCHED_PORT:PORT_5:k=1:u=1:e=0:i=0:c=0:t=0, short name: 'UOPS_D' with code 0x5380a1
Pinned to CPU 0
lipfc init OK
Running benchmarks groups using timer libpfc

** Running benchmark group PortContention tests **
                     Benchmark   Cycles   UOPS_D   UOPS_D   UOPS_D   UOPS_D
                PortContention     2.00     2.00     1.01     1.01     1.00
```

Notice, how I specified the performance counters that I want to collect with `--extra-events` option. I did 1000 iterations, but the tool already calculated all the metrics per 1 iteration. So, we run at 2 cycles per iteration in which 2 uops were dispatched to PORT1 and ports 2, 3 and 5 handled 1 uop each.

## likwid
------

[Likwid](https://github.com/RRZE-HPC/likwid) is more than just a tool for doing microarchitectural benchmarking. It consists of many utilities for people doing HPC stuff. You can find the complete list on the main page of the tool. Here is the great [article](http://www.nersc.gov/users/software/performance-and-debugging-tools/likwid/) describing it's basic usages. Also likwid has very detailed [wiki](https://github.com/RRZE-HPC/likwid/wiki) so you can use it as well.

Here are the [instructions](https://github.com/RRZE-HPC/likwid/wiki/Build) how to build likwid tools. We will only use `likwid-perfctr` which allows to configure and read out hardware performance counters.

#### how to use it

Likwid has marker API but only for C/C++, so in order to write a benchmark I wrote a function in assembly and invoked it from C:

```cpp
#define N 10000

void benchmark(int iters, void* ptr);

int main(int argc, char* argv[])
{
    int data[N];
    LIKWID_MARKER_INIT;
    LIKWID_MARKER_THREADINIT;
    LIKWID_MARKER_START("foo");
    benchmark(N, data);
    LIKWID_MARKER_STOP("foo");
    LIKWID_MARKER_CLOSE;
    return 0;
}
```

```asm
GLOBAL benchmark

benchmark:
push rbx
push rcx

.loop:
mov eax, DWORD [rsi] 
mov eax, DWORD [rsi + 4]
bswap ebx
bswap ecx
dec rdi
jnz .loop

mov eax, 0

pop rcx
pop rbx

ret
```

I compiled everything like this:
```
$ export LIKWID_INCLUDE=/usr/local/bin/../include/
$ export LIKWID_LIB=/usr/local/bin/../lib/
$ nasm -f elf64 benchmark.asm
$ gcc -c -DLIKWID_PERFMON -I$LIKWID_INCLUDE test.c -o test.o 
$ gcc benchmark.o test.o -o a.out -L$LIKWID_LIB -llikwid
```

#### what is the output

```
$ export LD_LIBRARY_PATH="$LIKWID_LIB:$LD_LIBRARY_PATH"
$ likwid-perfctr -C S0:0 -g UOPS_DISPATCHED_PORT_PORT_1:PMC0,UOPS_DISPATCHED_PORT_PORT_2:PMC1,UOPS_DISPATCHED_PORT_PORT_3:PMC2,UOPS_DISPATCHED_PORT_PORT_5:PMC3 -m ./a.out
--------------------------------------------------------------------------------
CPU name:	Intel(R) Core(TM) i3-3220T CPU @ 2.80GHz
CPU type:	Intel Core IvyBridge processor
CPU clock:	2.79 GHz
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Region foo, Group 1: Custom
+-------------------+----------+
|    Region Info    |  Core 0  |
+-------------------+----------+
| RDTSC Runtime [s] | 0.000014 |
|     call count    |        1 |
+-------------------+----------+

+-----------------------------+---------+--------------+
|            Event            | Counter |    Core 0    |
+-----------------------------+---------+--------------+
|     Runtime (RDTSC) [s]     |   TSC   | 1.399020e-05 |
| UOPS_DISPATCHED_PORT_PORT_1 |   PMC0  |        21010 |
| UOPS_DISPATCHED_PORT_PORT_2 |   PMC1  |        11035 |
| UOPS_DISPATCHED_PORT_PORT_3 |   PMC2  |        11169 |
| UOPS_DISPATCHED_PORT_PORT_5 |   PMC3  |        12097 |
|      INSTR_RETIRED_ANY      |  FIXC0  |        64462 |
|    CPU_CLK_UNHALTED_CORE    |  FIXC1  |        36128 |
|     CPU_CLK_UNHALTED_REF    |  FIXC2  |        63224 |
+-----------------------------+---------+--------------+
```

Notice, that again I was able to specify the counters I want to measure using `-g` option. Keeping in mind that we did 10000 iterations, results somewhat match with uarch-bench (see above).

Sources and output of this experiment can be found on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/Tools_for_microarchitectural_benchmarking/likwid).

## Benchmarking using assembly instructions
------

In theory it is possible to write the benchmark and collect performance counters yourself using special assembly instructions. It might be useful, for example, on bare metal systems.

I haven't tried it myself but if someone decides to go that road here is some links to start with:
- [How to Benchmark Code Execution Times on Intel® IA-32 and IA-64 Instruction Set Architectures](https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/ia-32-ia-64-benchmark-code-execution-paper.pdf)
- [How to read performance counters by rdpmc instruction?](https://software.intel.com/en-us/forums/software-tuning-performance-optimization-platform-monitoring/topic/595214)
