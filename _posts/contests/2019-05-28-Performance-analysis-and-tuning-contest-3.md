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

To run the benchmark, first copy `lua.test_run.script` and `lua.test_verify.script` from my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/3) and put them into `MultiSource/Applications/lua`:
```bash
$ cd MultiSource/Applications/lua
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

Lua interpreter is a typical parser, where the most time spent in a loop with a big switch. This switch interprets operations as it goes thought the script.

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

---

## _Updated 5th June 2019_

This benchmark is not an easy one to optimize. It represents a typical parser which often has a hotspot in a big switch inside the loop. The idea is that the lua interpreter reads the next token and depending on it's type perform a special action with this token. This simple implementation usually ends up with a indirect jump through a jump table. I.e. the switch statement is converted into a jump table with code path for every case.

```cpp
void execute(...)
{
  for (...)
  {
    auto token = readToken();
    swicth(token.getType())
    {
      // impl for every token type;
    }
  }
}
```

### Observations

First, we can expect that there will be a big probability of this indirect branch being mispredicted. This is the case for our benchmark, and as we will see later it's not so easy to fight those mispredictions.

Secondary, such implementation often results in a bad code layout, since the indirect jump can go anywhere (almost). We might not have this code in the I-cache and hot path is not organized in fall through manner, so CPU frontend doesn't like this, since I-cache utilization isn't optimal for such constructs.

Here is a bottlenecks break down (see [Top-Down methodology]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology)):

```bash
$ ~/pmu-tools/toplev.py --core S0-C0 -l2 --no-multiplex -v --no-desc taskset -c 0 ./lua.test_run.script

S0-C0    FE             Frontend_Bound:                              9.30 +-     0.00 % Slots below
S0-C0    BAD            Bad_Speculation:                            11.85 +-     0.00 % Slots      
S0-C0    BE             Backend_Bound:                              12.57 +-     0.00 % Slots       <==
S0-C0    RET            Retiring:                                   67.23 +-     0.00 % Slots below
S0-C0    FE             Frontend_Bound.Frontend_Latency:             3.32 +-     0.00 % Slots below
S0-C0    FE             Frontend_Bound.Frontend_Bandwidth:           6.25 +-     0.00 % Slots below
S0-C0    BAD            Bad_Speculation.Branch_Mispredicts:         11.67 +-     0.00 % Slots      
S0-C0    BAD            Bad_Speculation.Machine_Clears:              0.18 +-     0.00 % Slots below
S0-C0    BE/Mem         Backend_Bound.Memory_Bound:                  3.10 +-     0.00 % Slots below
S0-C0    BE/Core        Backend_Bound.Core_Bound:                    9.46 +-     0.00 % Slots below
S0-C0    RET            Retiring.Base:                              67.01 +-     0.00 % Slots below
S0-C0    RET            Retiring.Microcode_Sequencer:                0.22 +-     0.00 % Slots below
```

Here are the top hotspots in the benchmark:
```bash
$ perf record ./lua.test_run.script
$ perf report -n --stdio
# Overhead       Samples  Command        Shared Object      Symbol                                  
# ........  ............  .............  .................  ........................................
    41.77%         16637  lua            lua                [.] luaV_execute
     7.52%          2996  lua            lua                [.] luaH_get
     5.06%          2014  lua            lua                [.] luaV_gettable
     4.70%          1872  lua            lua                [.] luaD_precall
     3.30%          1315  lua            lua                [.] luaV_settable
```

Here are the things that I and other participants were able to find. I will list all the failed and successful attempts.

### Specializing the hot switch statement (negative impact)

The top hotspot of the benchmark is the big switch inside `luaV_execute`. First of all, let's explore if there are any cases in the switch that are executed more frequently than the others. It can be done using the [method]({{ site.url }}/blog/2019/05/06/Estimating-branch-probability) I described earlier. I found the 5 hottest cases in the switch.

```
case OP_GETUPVAL: 8301 samples
case OP_FORLOOP:  6471 samples
case OP_ADD:      6110 samples
case OP_GETTABLE: 5782 samples
case OP_TEST:     5531 samples
```

This doesn't look very much promising, i.e. we don't have any particular outliers in this distribution. Say, if we would have one case statement that was executed 90% of the time then we could specialize the switch for it, see below how to do this.

The first thing I tried was to put them all together, so that they would reside right at the beginning of the jump table. I did so by reordering the enum where those operations are defined, so that those top 5 guys would reside together in the code layout and right after the indirect branch. This is supposed to improve the code locality. 

```cpp
typedef enum {
/*----------------------------------------------------------------------
name		args	description
------------------------------------------------------------------------*/
OP_MOVE,/*	A B	R(A) := R(B)					*/
OP_LOADK,/*	A Bx	R(A) := Kst(Bx)					*/
OP_LOADBOOL,/*	A B C	R(A) := (Bool)B; if (C) pc++			*/
OP_LOADNIL,/*	A B	R(A) := ... := R(B) := nil			*/
OP_GETUPVAL,/*	A B	R(A) := UpValue[B]				*/
...
==>

typedef enum {
/*----------------------------------------------------------------------
name		args	description
------------------------------------------------------------------------*/
OP_GETUPVAL,/*	A B	R(A) := UpValue[B]				*/
OP_FORLOOP,/*	A sBx	R(A)+=R(A+2);
			if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }*/
OP_ADD,/*	A B C	R(A) := RK(B) + RK(C)				*/
OP_GETTABLE,/*	A B C	R(A) := R(B)[RK(C)]				*/
OP_TEST,/*	A C	if not (R(A) <=> C) then pc++			*/ 
...
```

This caused benchmark validation failure, I didn't debug why it happened. So I reverted this change.

I also tried to specialize the switch to check for the most frequent cases first, i.e.
```cpp
if (GET_OPCODE(i) == OP_GETUPVAL) {
  ...
}
else
{
  switch (GET_OPCODE(i)) {
    ...
  }
}
```
The idea is not to take an indirect jump (through the jump table) every time in the hot path. That didn't help either since `OP_GETUPVAL` doesn't execute often enough to outweigh the cost of doing additional comparison. I.e. now most of the time we do check for specialized case (`if (GET_OPCODE(i) == OP_GETUPVAL)`) and indirect jump which made the things even worse. I tried different specializations including all 5 top hottest cases, but the result was negative.

### Inlining functions with hot prolog and epilog (+2.65%)

It could be noticed that there are some functions with hot prolog. Usually this is an indication that we might have performance boost after inlining them. For example:

```bash
$ perf annotate --stdio -M intel luaV_gettable
 Percent |      Source code & Disassembly of lua for cycles (2014 samples)
--------------------------------------------------------------------------
         :
         :      Disassembly of section .text:
         :
         :      0000000000418be0 <luaV_gettable>:
         :      luaV_gettable():
    3.77 :        418be0:       push   r15	  <== prolog
    4.62 :        418be2:       mov    r15d,0x64
    2.14 :        418be8:       push   r14
    1.34 :        418bea:       mov    r14,rsi
    3.43 :        418bed:       push   r13
    3.08 :        418bef:       mov    r13,rdi
    1.24 :        418bf2:       push   r12
    1.14 :        418bf4:       mov    r12,rcx
    3.08 :        418bf7:       push   rbp
    3.43 :        418bf8:       mov    rbp,rdx
    1.94 :        418bfb:       push   rbx
    0.50 :        418bfc:       sub    rsp,0x8
    ...
    #                                             <== function body
    ...
    4.17 :        418d43:       add    rsp,0x8	  <== epilog
    3.67 :        418d47:       pop    rbx
    0.35 :        418d48:       pop    rbp
    0.94 :        418d49:       pop    r12
    4.72 :        418d4b:       pop    r13
    4.12 :        418d4d:       pop    r14
    0.00 :        418d4f:       pop    r15
    1.59 :        418d51:       ret  
```

You can see that ~50% of the time is spent in prolog and epilog. That should be a sign for us to try to force the inlining of this function. Note that not even though the function looks like a valid candidate to be inlined, it might not always be possible. Two most frequent cases are with recursive functions and functions that are called indirectly (e.g. virtual functions). In compiler terminology it's named as function's address being taken and usually we can't inline such functions. Although even here there are some tricks.

Three functions can be inlined with positive impact (+2.65%): `luaH_get`, `luaV_gettable`, `luaD_precall`. Here is the [patch on my github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/PerfContest/3/inlining.patch) that does that.

### Improving machine block placement (+1.62%)
```bash
$ perf annotate --stdio -M intel -l luaV_execute

 Percent |      Source code & Disassembly of lua for cycles (16637 samples)
---------------------------------------------------------------------------
         :
         :      Disassembly of section .text:
         :
         :      0000000000416630 <luaV_execute>:
         :      luaV_execute():
    0.02 :        416630:       push   r15
    0.03 :        416632:       push   r14
    0.01 :        416634:       push   r13
    0.00 :        416636:       push   r12
    0.00 :        416638:       push   rbp
    0.01 :        416639:       mov    rbp,rdi
    0.01 :        41663c:       push   rbx
    0.00 :        41663d:       sub    rsp,0x68
    0.04 :        416641:       mov    r15,QWORD PTR [rdi+0x18]
    0.02 :        416645:       mov    rax,QWORD PTR [rdi+0x28]
    0.00 :        416649:       mov    DWORD PTR [rsp+0x24],esi
    0.02 :        41664d:       lea    rsi,[rdi+0x98]
    0.01 :        416654:       mov    r14,QWORD PTR [rdi+0x30]
    0.01 :        416658:       mov    QWORD PTR [rsp+0x18],rsi
    0.00 :        41665d:       mov    r11,r15
    0.45 :        416660:       mov    rax,QWORD PTR [rax+0x8]
    0.22 :        416664:       mov    r13,r11
    0.07 :        416667:       mov    r10,QWORD PTR [rax]
    0.57 : LOOP-> 41666a:       mov    rax,QWORD PTR [r10+0x20]
    1.95 :        41666e:       mov    r11,r10
    0.02 :        416671:       mov    rax,QWORD PTR [rax+0x10]
    2.02 :        416675:       mov    QWORD PTR [rsp+0x10],rax
    0.50 :        41667a:       nop    WORD PTR [rax+rax*1+0x0]
    2.27 :        416680:       movzx  eax,BYTE PTR [rbp+0x64]
    2.03 :        416684:       mov    r15d,DWORD PTR [r14]
    1.77 :        416687:       lea    rbx,[r14+0x4]
    3.29 :        41668b:       test   al,0xc
    0.00 :    ┌── 41668d:       je     416732 <luaV_execute+0x102>
    0.00 :    │   # some amount 
    0.00 :    │   # of cold code
    1.96 :    └─> 416732:       mov    eax,r15d
    1.65 :        416735:       shr    eax,0x6
    1.27 :        416738:       movzx  r10d,al
    3.16 :        41673c:       movzx  eax,al
    2.18 :        41673f:       shl    rax,0x4
    1.80 :        416743:       mov    rcx,rax
    0.96 :        416746:       lea    r12,[r13+rax*1+0x0]
```

It is beneficial to invert this branch to make the hot path fall through via not taken branch. See another example of this optimization [here]({{ site.url }}/blog/2019/04/10/Performance-analysis-and-tuning-contest-2#improving-machine-block-placement-15) and graphical explanation in the post [Machine code layout optimizations]({{ site.url }}/blog/2019/03/27/Machine-code-layout-optimizatoins#basic-block-placement)

### Optimizations summary

Here is the summary of optimizations that could be made for this benchmark including using PGO[^2]:
```
 time(s)   submission         timings for 10 consecutive runs (s)                                     speedup
([9.54,  'baseline_with_PGO', [9.54, 9.57, 9.61, 9.62, 9.63, 9.63, 9.64, 9.65, 9.68, 9.74]],          ' + 4.92%')
([9.6,   'builtin_inlining',  [9.6, 9.62, 9.63, 9.63, 9.65, 9.65, 9.67, 9.68, 9.71, 9.74]],           ' + 4.27%')
([9.85,  'builtin',           [9.85, 9.86, 9.87, 9.87, 9.9, 9.91, 9.93, 10.34, 10.63, 11.97]],        ' + 1.62%')
([10.01, 'baseline',          [10.01, 10.03, 10.03, 10.03, 10.05, 10.05, 10.1, 10.13, 10.14, 10.27]], ' + 0.0%')
```

Please let me know if you find other ways to speed up this benchmark.

------
[^1]: I checked mid May 2019 versions of Clang and GCC.
[^2]: I wrote a little bit about PGO [here]({{ site.url }}/blog/2019/03/27/Machine-code-layout-optimizatoins#profile-guided-optimizations-pgo). Guide for using PGO in clang in [here](https://clang.llvm.org/docs/UsersManual.html#profiling-with-instrumentation).
