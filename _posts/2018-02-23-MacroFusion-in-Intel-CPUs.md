---
layout: post
title: MacroFusion in Intel CPUs.
tags: default
---

**Contents:**
* TOC
{:toc}

In my [previous post](https://dendibakh.github.io/blog/2018/02/15/MicroFusion-in-Intel-CPUs) I wrote about MicroFusion which is the thing that happens when multiple uops from the same assembly instruction are fused into one. Another interesting feature of Intel Architecture (IA) that was introduced in Core2 and Nehalem architectures is *MacroFusion*. It names the situation when uops from different assembly instruction fuse together into one uops.

Description of it can be found in [microarchitecture manual](www.agner.org/optimize/microarchitecture.pdf) by Agner Fog:
> The decoders will fuse arithmetic or logic instruction with a subsequent conditional jump instruction into a single compute-and-branch µop in certain cases. The compute-and-branch µop is not split in two at the execution units but executed as a single µop by the branch unit. This means that macro-op fusion saves bandwidth in all stages of the pipeline from decoding to retirement.

### Example

```asm
.loop:
dec rdi
jnz .loop
ret
```
There is not much useful work done inside this assembly, but it it the easiest example of MacroFusion. We just decrement `rdi` on each iteration and when it reaches 0, just exit the loop and return.

As before I did my experiments on Ivy Bridge processor using [uarch-bench](https://github.com/travisdowns/uarch-bench) tool:
```
Benchmark           Cycles   INSTRUCTIONS_RETIRED   UOPS_RETIRED.RETIRE_SLOTS   UOPS_RETIRED.ALL
dec + jnz           1.02     2.00                   1.00                        1.00
```
The counters I mentioned above:
- **UOPS_RETIRED.RETIRE_SLOTS** - Counts the number of retirement slots used each cycle. (fused domain)
- **UOPS_RETIRED.ALL** - Counts the number of micro-ops retired. (unfused domain)

You can find more detailed description of them in my [MicroFusion post](https://dendibakh.github.io/blog/2018/02/15/MicroFusion-in-Intel-CPUs).

As we can see that the number of instructions retired at each cycle is 2. But they are fused in the decoders into one uop, which is executed as fused. We can state this because number of uops retired is the same in fused and unfused domains.

### Limitations

There is number of limitations which varies across different architectures. For example, if you put nop in between it will break MacroFusion:
```asm
.loop:
dec rdi
nop
jnz .loop
ret
```
Measurements:
```
Benchmark           Cycles   INSTRUCTIONS_RETIRED   UOPS_RETIRED.RETIRE_SLOTS   UOPS_RETIRED.ALL
dec + nop + jnz     1.02     3.00                   3.00                        3.00
```
Here we can see that no MacroFusion happens in this case. This limitation is valid even for Skylake architecture. I will quote Agner here:
> The programmer should keep fuseable arithmetic instructions together with a subsequent conditional jump rather than scheduling other instructions in-between.

I will not mention other limitations, it's best to read about them in [microarchitecture manual](www.agner.org/optimize/microarchitecture.pdf) (just search for MacroFusion).

### Micro + Macro Fusion.

It is possible to have micro-op and macro-op fusion at the same time:

```asm
.loop:
add rsi, 4
cmp DWORD [rsi], edi
jnz .loop
ret
```

This code is searching for a value `edi` in an array that is indexed by `rsi`. I'm calling this assembly function like that:
```cpp
int a[1024];
for (int i = 0; i < 1024; ++i)
{
  a[i] = i;
}
// according to x86 calling conventions first two arguments 
// will land in rdi and rsi respectively.
benchmark_func(1024, a);
```

In this example `cmp` instruction effectively does a load and compare operations, but due to [Microfusion](https://dendibakh.github.io/blog/2018/02/15/MicroFusion-in-Intel-CPUs) those uops are fused into one. Moreover, this uop is macro-fused with `jnz` instruction.

```
Benchmark           Cycles   INSTRUCTIONS_RETIRED   UOPS_RETIRED.RETIRE_SLOTS   UOPS_RETIRED.ALL
micro + macro       1.10     3.00                   2.00                        3.00
```

Here we can see that we have 2 uop in fused domain: `inc` and micro-macro-fused. But later this micro-macro-fused uop was split at the execution unit, resulting in total 3 uops in unfused domain.

