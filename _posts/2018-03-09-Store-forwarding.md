---
layout: post
title: Store forwarding by example.
tags: default
---

**Contents:**
* TOC
{:toc}

In this post I will discussed another interesting feature of Intel processor that is called *store forwarding*.

### Store to load forwarding

In order to describe it I will quote Agner's Fog [microarchitecture.pdf](http://www.agner.org/optimize/microarchitecture.pdf):
> The processor can forward a memory write to a subsequent read from the same address under certain conditions. Store forwarding works if a write to memory is followed by a read from the same address when the read has the same operand size.

Here is the example of a successful store to load forwarding:

```asm
mov DWORD [esi], edi
mov eax, DWORD [esi] 
```
In this example the temporary 4-byte store will be kept in Store Buffer without even writing it to L1. Load will take those 4 bytes directly from Store Buffer.

But there are some situations where store to load forwarding fails. For example:

```asm
mov WORD [esi], di   ; small write
mov eax, DWORD [esi] ; big read (stall)
```

### Experiments

I put all those two examples in a tight loop and microbenchmarked them using [uarch-bench](https://github.com/travisdowns/uarch-bench) tool.

*successful store forwarding:*
```asm
.loop:
mov DWORD [esi + edi * 4], edi
mov eax, DWORD [esi + edi * 4] 
dec edi
jnz .loop
```

*big read after small write:*
```asm
.loop:
mov WORD [esi + edi * 4], di   ; small write
mov eax, DWORD [esi + edi * 4] ; big read (stall)
dec edi
jnz .loop
ret
```

### Counters that I use

I did my experiments on IvyBridge CPU. The counters that I will show are (details [here](https://download.01.org/perfmon/index/ivybridge.html)):

- **LD_BLOCKS.STORE_FORWARD** - Loads blocked by overlapping with store buffer that cannot be forwarded.
- **UOPS_RETIRED.STALL_CYCLES** - Cycles without actually retired uops. 

### Results

The benchmark runs 1000 iterations of this loop and the counters presented below are per iteration:

```
                     Benchmark   Cycles     LD_BLOCKS.STORE_FORWARD   UOPS_RETIRED.STALL_CYCLES
   successful store forwarding     1.02     0.00                      0.02
    big read after small write    15.00     1.00                      14.00
```

So, here you can see that we are running super fast when nothing prevents store to load forwarding. Everything is nicely pipelined. But when store forwarding failed we run 15 times worse, which is really nasty. The `LD_BLOCKS.STORE_FORWARD` counter shows us that we have 1 such issue per iteration which results in additional 14 penalty cycles per iteration. 

But according to Agner's Fog [microarchitecture.pdf](http://www.agner.org/optimize/microarchitecture.pdf) on the SandyBridge family the penalty for a failed store forwarding is approximately 12 clock cycles in most cases. But we see 14 cycles penalty.

Because load-store reordering is not allowed in x86 (even though store-load is) only one blocked load can execute at a time and perhaps the subsequent stores (on next iterations) are also blocked from committing to preserve memory ordering. I think that explains why why we might have additional 2 cycles penalty, although I'm not 100% sure in that.

But also I think that doesn't mean that the whole pipe is stalled. If you will add lots of math instructions in the loop, they will not be blocked:

```asm
mov WORD [esi + edi * 4], di   ; small write
mov eax, DWORD [esi + edi * 4] ; big read (stall)
add ebx, 1                     ; not stalled
```

### What else can prevent store forwarding?

You can have the same effect when load start address is not the same as store start address. Example:

```asm
mov DWORD [esi], edi
mov eax, DWORD [esi + 1] ; not the same start address (stall)
```

When I benchmarked this assembly sequence I basically received the same numbers as for "big read after small write" case.

The best way to find complete list of things that can prevent store forwarding for particular architecture is to find them in [microarchitecture.pdf](http://www.agner.org/optimize/microarchitecture.pdf).

### One more interesting experiment

I did one more interesting experiment where I tried to hide the store forwarding fail under another store forwarding fail.
I did 2 experiments, where I'm just accessing one cache line, writing 2 bytes and reading 4 bytes at a time (store forwarding stall) :

*full unroll*
```asm
mov WORD [esi], di
mov eax, DWORD [esi]
mov WORD [esi + 4], di
mov eax, DWORD [esi + 4]
mov WORD [esi + 8], di
mov eax, DWORD [esi + 8]
; ... more stores and loads
mov WORD [esi + 60], di
mov eax, DWORD [esi + 60]
```

*full interleave*
```asm
mov WORD [esi], di
mov WORD [esi + 4], di
mov WORD [esi + 8], di
; ... more stores
mov WORD [esi + 60], di

mov eax, DWORD [esi]
mov eax, DWORD [esi + 4]
mov eax, DWORD [esi + 8]
; ... more loads
mov eax, DWORD [esi + 60]
```

The difference is that in "full unroll" loads and stores are intermixed, but in "full interleave" I first write to the entire cache line and after that start reading from it.

Results:
```
                     Benchmark   Cycles   LD_BLOCKS.STORE_FORWARD   UOPS_RETIRED.STALL_CYCLES
       cache line: full unroll   235.00    16.00                     220.00
   cache line: full interleave    29.00    16.00                     4.00
```

From this experiment you can see that in "full unroll" case every time we experience store forwarding stall we stop right there. But in the second case we were almost fully able to hide all the store forwarding penalty. But notice that the number of `LD_BLOCKS.STORE_FORWARD` is the same in both cases.

### Conclusion

I hope that now you understand what store forwarding is and you will be able to detect issues with it in a real case.
