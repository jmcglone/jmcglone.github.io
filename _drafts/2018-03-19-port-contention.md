---
layout: post
title: Port contention.
tags: default
---

Modern processors have multiple execution units. For example, in SandyBridge family there 6 total execution ports:
- Ports 0,1,5
- Port 2,3
- Port 4

### Example 1: utilizing full load capacity 

We have 2 ports for executing loads, meaning that we can schedule 2 loads at the same time. Let's look at first example where we will try to read one cache line (64 B) in portions of 4 bytes. So, we will have 16 reads of 4 bytes. I make reads within one cache-line in order to eliminate cache effects. I will repeat this 1000 times:

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

### Counters that I use

- **UOPS_DISPATCHED_PORT.PORT_X**
- **UOPS_EXECUTED.STALL_CYCLES**
- **UOPS_EXECUTED.CYCLES_GE_X_UOP_EXEC**

### Results

I did my experiments on IvyBridge CPU using [uarch-bench tool]().
```
                     Benchmark   Cycles   UOPS.PORT2   UOPS.PORT3   UOPS.PORT5
             max load capacity   8.02     8.00         8.00         1.00  
```

We can see that our 16 loads were scheduled equally between PORT2 and PORT3, each port takes 8 uops. PORT5 takes [MacroFused]() uop appeared from `dec` and `jnz` instruction.
The same picture can be observed if use [IACA]() tool:
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
### Now let's understand why we have 8 cycles per iteration.
According to Agner's [instruction_tables.pdf]() load instruction that I use has 2 cycles latency. We have `(16 [loads] * 2 [cycles]) / 2 [ports] = 16`. According to this calculations we should receive 16 cycles per iteration. But we are running at 8 cycles per iteration. This happens because load units are also pipelined, meaning that we can start second load while first load is in progress on the same port.

It can be better seen on the [pipeline diagram]():
![](/img/posts/PortContention/Pipeline1.png){: .center-image }

This is simplified MIPS-like pipeline diagram, where we usually have 5 pipeline stages: F(fetch), D(decode), I()
however I preserved some important constraints 
