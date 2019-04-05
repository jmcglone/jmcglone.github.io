---
layout: post
title: Understanding performance events skid.
tags: default
---

**Contents:**
* TOC
{:toc}

In my previous article I promised to write about retired instructions, reference cycles and other stuff. But one of my readers asked me why he sometimes sees an instruction tagged by an event which was not caused by this instruction? So, today I want to discuss this very important concept, which I think is crucial to understand.

Performance analysis is a hard thing, no question about it. But it becomes even harder when the profile data that you are looking at misleads you. Imagine you have application with big amount of L1D-cache misses and the hot assembly code that look like this:
```asm
; load1 
; load2
; load3 <-- here profile shows you lots of L1D-cache misses
```

This is great, but in reality load1 is the instruction that causes L1D-cache misses. Ugghf!

The *skid* is defined as the distance between the IP(s) that caused the issue to the IP(s) where the event is tagged

### Example of skid

To demonstrate the thing I wrote a small test in assembly that is available on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/Skid/skid.asm). Inside it I have a simple loop:
```asm
; there will be 100'000'000 iterations
.loop:

; cache_line of 8-byte NOPs
; cache_line of 8-byte NOPs
; cache_line of 8-byte NOPs
; cache_line of 8-byte NOPs

dec rdi
jnz .loop
```

For the purpose of the experiment we don't need to have real assembly instructions. We will emulate the workload with NOPs. In my experiment we will sample on the event `branches (BR_INST_RETIRED.ALL_BRANCHES)` and expect all such events to correspond to `jnz .loop` instruction. I made all experiments on Haswell CPU:
```bash
$ perf stat -e cpu/event=0xc4,umask=0x4,name=BR_INST_RETIRED.ALL_BRANCHES/ ./a.out
 Performance counter stats for './a.out':
         100338645      BR_INST_RETIRED.ALL_BRANCHES                                   
       0,301300877 seconds time elapsed
```
Total number of branches retired is close to `100'000'000` (1 branch per iteration). Now let's sample on it:
```bash
$ perf record -e cpu/event=0xc4,umask=0x4,name=BR_INST_RETIRED.ALL_BRANCHES/ ./a.out
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.062 MB perf.data (1176 samples) ]
$ perf annotate --stdio -M intel main.loop
 Percent |      Source code & Disassembly of a.out for BR_INST_RETIRED.ALL_BRANCHES (1170 samples)
--------------------------------------------------------------------------------------------------
         :
         :
         :
         :      Disassembly of section .text:
         :
         :      000000000040057e <main.loop>:
         :      main.loop():
    0.00 :        40057e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400586:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40058e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400596:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40059e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005a6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005ae:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005b6:       nop    DWORD PTR [rax+rax*1+0x0]
  100.00 :        4005be:       nop    DWORD PTR [rax+rax*1+0x0]	<-- OOOPS, we have skid of ~10 instructions!
    0.00 :        4005c6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005ce:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005d6:       nop    DWORD PTR [rax+rax*1+0x0]	
    0.00 :        4005de:       nop    DWORD PTR [rax+rax*1+0x0]	<-- This insruction is tagged on Ivy Bridge CPU.
    0.00 :        4005e6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005ee:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005f6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005fe:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400606:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40060e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400616:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40061e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400626:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40062e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400636:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40063e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400646:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40064e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400656:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40065e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400666:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40066e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400676:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40067e:       dec    rdi
    0.00 :        400681:       jne    40057e <main.loop>		<-- This instruction should be tagged.
    0.00 :        400687:       add    rsp,0x4
    0.00 :        40068b:       pop    rdi
    0.00 :        40068c:       pop    rax
    0.00 :        40068d:       ret    
    0.00 :        40068e:       ud2 
```
Notice, that all collected samples correspond to the wrong instruction! To understand why that happens you might want to check one of my previous articles: [Advanced profiling topics PEBS and LBR](https://dendibakh.github.io/blog/2018/06/08/Advanced-profiling-topics-PEBS-and-LBR). But if you want to know the short answer, there is a delay between performance monitoring interrupt issued and capture of instruction pointer (IP). 

### What we can do about it?

Skid makes it difficult to discover the instruction which is actually causing the performance issue. But fortunately, there is a special mechanism called PEBS (Precise Event-Based Sampling) which is dedicated to solve the problem. More on this topic I wrote in already mentioned blog post. Here is how the things changed when using it (notice `pp` suffix in the event declaration):
```bash
$ perf record -e cpu/event=0xc4,umask=0x4,name=BR_INST_RETIRED.ALL_BRANCHES/pp ./a.out
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.064 MB perf.data (1245 samples) ]
$ perf annotate --stdio -M intel main.loop
 Percent |      Source code & Disassembly of a.out for BR_INST_RETIRED.ALL_BRANCHES (1237 samples)
--------------------------------------------------------------------------------------------------
         :
         :
         :
         :      Disassembly of section .text:
         :
         :      000000000040057e <main.loop>:
         :      main.loop():
    0.00 :        40057e:       nop    DWORD PTR [rax+rax*1+0x0] <-- This instruction is tagged for SNB families.
    0.00 :        400586:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40058e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400596:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40059e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005a6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005ae:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005b6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005be:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005c6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005ce:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005d6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005de:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005e6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005ee:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005f6:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        4005fe:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400606:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40060e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400616:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40061e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400626:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40062e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400636:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40063e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400646:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40064e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400656:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40065e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400666:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40066e:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        400676:       nop    DWORD PTR [rax+rax*1+0x0]
    0.00 :        40067e:       dec    rdi
  100.00 :        400681:       jne    40057e <main.loop>	 <-- Indeed, this is the instruction, we were looking for.
    0.00 :        400687:       add    rsp,0x4
    0.00 :        40068b:       pop    rdi
    0.00 :        40068c:       pop    rax
    0.00 :        40068d:       ret    
    0.00 :        40068e:       ud2
```

Now we have clear picture of the event that we sample on and the instruction that caused it. However, keep in mind, that only since Haswell precise events tag the same instruction, but on SandyBridge processor family they skid to the next IP (see the listing above).

Precise events is a very important tool for [top-down analysis](http://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-optimization-manual.html) (look at Appendix B.1). It's idea that you first identify the source of the performance problems. You basically do this by counting a lot of events at once (not necessary precise). You understand what is causing problems and than you locate the exact place in the code using precise event. For more details and examples take a look at [TMA metrics](https://download.01.org/perfmon/TMA_Metrics.xlsx).
