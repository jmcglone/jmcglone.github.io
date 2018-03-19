---
layout: post
title: Port contention.
tags: default
---

Modern processors have multiple execution units. For example, in SandyBridge family there are 6 execution ports:
- Ports 0,1,5 are for arithmetic and logic operations (ALU).
- Ports 2,3 are for memory reads.
- Port 4 is for memory write.

Today I will try to stress this side of my IvyBridge CPU. I will show when port contention can take place, will present easy to understand [pipeline diagramms](https://en.wikipedia.org/wiki/Instruction_pipelining) and even try [IACA](https://software.intel.com/en-us/articles/intel-architecture-code-analyzer). It will be very interesting, so keep on reading!

> Disclaimer: I don't want to describe some nuances of IvyBridge achitecture, but rather to show how port contention might look in practice.

### Example 1: utilizing full load capacity 

In my IvyBridge CPU I have 2 ports for executing loads, meaning that we can schedule 2 loads at the same time. Let's look at first example where I will read one cache line (64 B) in portions of 4 bytes. So, we will have 16 reads of 4 bytes. I make reads within one cache-line in order to eliminate cache effects. I will repeat this 1000 times:

*max load capacity*

```asm
; esi contains the beginning of the cache line
; edi contains number of iterations (1000)
.loop:
mov eax, DWORD [esi] 
mov eax, DWORD [esi + 4]
mov eax, DWORD [esi + 8] 
mov eax, DWORD [esi + 12] 
mov eax, DWORD [esi + 16] 
mov eax, DWORD [esi + 20] 
mov eax, DWORD [esi + 24] 
mov eax, DWORD [esi + 28] 
mov eax, DWORD [esi + 32] 
mov eax, DWORD [esi + 36] 
mov eax, DWORD [esi + 40] 
mov eax, DWORD [esi + 44] 
mov eax, DWORD [esi + 48] 
mov eax, DWORD [esi + 52] 
mov eax, DWORD [esi + 56]
mov eax, DWORD [esi + 60]    
dec edi
jnz .loop
```

### Performance counters that I use

- **UOPS_DISPATCHED_PORT.PORT_X** - Cycles when a uop is dispatched on port X.
- **UOPS_EXECUTED.STALL_CYCLES** - Counts number of cycles no uops were dispatched to be executed on this thread.
- **UOPS_EXECUTED.CYCLES_GE_X_UOP_EXEC** - Cycles where at least X uops was executed per-thread.

Full list of performance counters for IvyBridge can be found [here](https://download.01.org/perfmon/index/ivybridge.html).

### Results

I did my experiments on IvyBridge CPU using [uarch-bench tool](https://github.com/travisdowns/uarch-bench).
```
                     Benchmark   Cycles   UOPS.PORT2   UOPS.PORT3   UOPS.PORT5
             max load capacity   8.02     8.00         8.00         1.00  
```

We can see that our 16 loads were scheduled equally between PORT2 and PORT3, each port takes 8 uops. PORT5 takes [MacroFused]() uop appeared from `dec` and `jnz` instruction.
The same picture can be observed if use [IACA](https://software.intel.com/en-us/articles/intel-architecture-code-analyzer) tool ([good explanation](https://stackoverflow.com/questions/26021337/what-is-iaca-and-how-do-i-use-it) how to use IACA):
```
Architecture  - IVB
Throughput Analysis Report
--------------------------
Block Throughput: 8.00 Cycles       Throughput Bottleneck: Backend. PORT2_AGU, Port2_DATA, PORT3_AGU, Port3_DATA

Port Binding In Cycles Per Iteration:
-------------------------------------------------------------------------
|  Port  |  0   -  DV  |  1   |  2   -  D   |  3   -  D   |  4   |  5   |
-------------------------------------------------------------------------
| Cycles | 0.0    0.0  | 0.0  | 8.0    8.0  | 8.0    8.0  | 0.0  | 1.0  |
-------------------------------------------------------------------------

N - port number or number of cycles resource conflict caused delay, DV - Divider pipe (on port 0)
D - Data fetch pipe (on ports 2 and 3), CP - on a critical path
F - Macro Fusion with the previous instruction occurred

| Num Of |              Ports pressure in cycles               |    |
|  Uops  |  0  - DV  |  1  |  2  -  D  |  3  -  D  |  4  |  5  |    |
---------------------------------------------------------------------
|   1    |           |     | 1.0   1.0 |           |     |     | CP | mov eax, dword ptr [rsp]
|   1    |           |     |           | 1.0   1.0 |     |     | CP | mov eax, dword ptr [rsp+0x4]
|   1    |           |     | 1.0   1.0 |           |     |     | CP | mov eax, dword ptr [rsp+0x8]
|   1    |           |     |           | 1.0   1.0 |     |     | CP | mov eax, dword ptr [rsp+0xc]
|   1    |           |     | 1.0   1.0 |           |     |     | CP | mov eax, dword ptr [rsp+0x10]
|   1    |           |     |           | 1.0   1.0 |     |     | CP | mov eax, dword ptr [rsp+0x14]
|   1    |           |     | 1.0   1.0 |           |     |     | CP | mov eax, dword ptr [rsp+0x18]
|   1    |           |     |           | 1.0   1.0 |     |     | CP | mov eax, dword ptr [rsp+0x1c]
|   1    |           |     | 1.0   1.0 |           |     |     | CP | mov eax, dword ptr [rsp+0x20]
|   1    |           |     |           | 1.0   1.0 |     |     | CP | mov eax, dword ptr [rsp+0x24]
|   1    |           |     | 1.0   1.0 |           |     |     | CP | mov eax, dword ptr [rsp+0x28]
|   1    |           |     |           | 1.0   1.0 |     |     | CP | mov eax, dword ptr [rsp+0x2c]
|   1    |           |     | 1.0   1.0 |           |     |     | CP | mov eax, dword ptr [rsp+0x30]
|   1    |           |     |           | 1.0   1.0 |     |     | CP | mov eax, dword ptr [rsp+0x34]
|   1    |           |     | 1.0   1.0 |           |     |     | CP | mov eax, dword ptr [rsp+0x38]
|   1    |           |     |           | 1.0   1.0 |     |     | CP | mov eax, dword ptr [rsp+0x3c]
|   1    |           |     |           |           |     | 1.0 |    | dec rdi
|   0F   |           |     |           |           |     |     |    | jnz 0xffffffffffffffbe
Total Num Of Uops: 17
```
### Why we have 8 cycles per iteration?
According to Agner's [instruction_tables.pdf](http://www.agner.org/optimize/optimizing_assembly.pdf) load instruction that I use has 2 cycles latency. We have `(16 [loads] * 2 [cycles]) / 2 [ports] = 16`. According to this calculations we should receive 16 cycles per iteration. But we are running at 8 cycles per iteration. Why this happens?

Well, like most of execution units, load units are also pipelined, meaning that we can start second load while first load is in progress on the same port. Let's draw a simplified [pipeline diagram](https://en.wikipedia.org/wiki/Instruction_pipelining) and see what's going on.
![](/img/posts/PortContention/Pipeline1.png){: .center-image }

This is simplified MIPS-like pipeline diagram, where we usually have 5 pipeline stages: 
1. F(fetch)
2. D(decode)
3. I(issue)
4. E(execute) or M(memory operation)
5. W(write back)

It is far from real execution diagram of my CPU, however, I preserved some important constraints for IvyBridge architecture (IVB):
- IVB front-end fetches 16B blocks of instructions in a 16B aligned window in 1 cycle.
- IVB has 4 decoders, each of them can decode instructions that consist of single uop.
- IVB has 2 pipelined units for doing load operations. Load operation takes 2 cycles (everything is in the cache), so we have M1 and M2.

Drawing such kind of diagrams usually helps me to undertand what is going on inside the processor and finding different sorts of hazards.

### Some explanations for this pipeline diagram

1. In first cycle we fetch 4 loads. We can't fetch LOAD5, because it doesn't fit in the same 16B aligned window as first 4 loads.
2. In second cycle we were able to decode all 4 fetched instructions, because they all are single-uop instructions.
3. In third cycle we were able to issue only first 2 loads. One of such load goes to PORT2, the second goes to PORT3. Notice, that LOAD3 and LOAD4 are stalled (typically waiting in Reservation Station).
4. Only in cycle #4 we were able to issue LOAD3 and LOAD4, because we know M1 stages will be free to use in next cycle.

Continuing this diagram further we could see that in each cycle we are able to retire 2 loads. We have 16 loads, so that explains why it takes only 8 cycles per iteration.

I made additional experiment to prove this theory. I collected some more performance counters:
```
                     Benchmark   Cycles   CYCLES_GE_3_UOP_EXEC   CYCLES_GE_2_UOP_EXEC   CYCLES_GE_1_UOP_EXEC
             max load capacity   8.02     1.00                   8.00                   8.00  
```

Results above show that in each of 8 cycles (that it took to execute one iteration) at least 2 uops were issued (two loads issued per cycle). And in one cycle we were able to issue 3 uops (last 2 loads + dec-jnz pair). Conditional branches are executed on PORT5, so nothing prevents us from scheduling it in parrallel with 2 loads.

