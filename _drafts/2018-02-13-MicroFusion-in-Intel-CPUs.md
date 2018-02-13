---
layout: post
title: MicroFusion in Intel CPUs.
tags: default
---

My previous post about [Instruction Fusion](https://dendibakh.github.io/blog/2018/02/04/Micro-ops-fusion) spawned lots of comments. What I really wanted to benchmark was fused assembly instructions, but it turned out that some other microarchitectural features were involved in that example, which I was not aware about.

With the help of Travis Downs and others from HackerNews I did more investigation on this and I want to summarize it in this post.

This post is not intended to cover all possible issues one can face. I rather want to present the high-level concept here. I did experiments only on IvyBridge architecture. In the end of the article I provide the links where you can find more details for particular architecture.

### MicroFusion

There is a nice explanation of MicroFusion in Agner's manual #3: [The microarchitecture of Intel, AMD and VIA CPUs: An optimization guide for assembly programmers and compiler makers](http://www.agner.org/optimize/microarchitecture.pdf) Chapter 7.6 (search for chapters with the same name for later architectures):

>In order to get more through these bottlenecks, the designers have joined some operations together that were split in two μops in previous processors. They call this μop fusion.
>
>
>The μop fusion technique can only be applied to two types of combinations: memory write operations and read-modify operations.

```asm
 ; Example 7.2. Uop fusion
 mov    [esi], eax               ; 1 fused uop
 add    eax, [esi]               ; 1 fused uop
 add    [esi], eax               ; 2 single + 1 fused uop
```

### Why do we want MicroFusion?

Again, I will better quote Agner here:

> μop fusion has several advantages:
> - Decoding becomes more efficient because an instruction that generates one fused μop can go into any of the three decoders while an instruction that generates two μops can go only to decoder D0.
> - The load on the bottlenecks of register renaming and retirement is reduced when fewer μops are generated.
> - The capacity of the reorder buffer (ROB) is increased when a fused μop uses only one entry.

### Fused/unfused domain

In order to understand all the benchmarks and the performance counters we need to know aboout fused and unfused domain.

`Describe counters that I will show.`

### Example 1: double fusion

```asm
add     DWORD [rsp + 4], 1
```

Full code of the assembly function can be found [here](). See also microbenchmarks integrated into [uarch-bench](https://github.com/travisdowns/uarch-bench/blob/0c4e467043d16dd955eaf09249a2f189f5ec2467/x86_methods.asm#L307).

```
Benchmark           Cycles   UOPS_RETIRED.RETIRE_SLOTS   UOPS_RETIRED.ALL
add [esp], 1        1.10     2.08                        4.08
```

### Example 2: half fusion

```asm
inc     DWORD [rsp + 4]
```

Full code of the assembly function can be found [here](). See also microbenchmarks integrated into [uarch-bench](https://github.com/travisdowns/uarch-bench/blob/0c4e467043d16dd955eaf09249a2f189f5ec2467/x86_methods.asm#L307).

```
Benchmark           Cycles   UOPS_RETIRED.RETIRE_SLOTS   UOPS_RETIRED.ALL
inc [esp]           1.12     3.08                        4.08
```

### Example 3: no fusion

```asm
add     DWORD [rsp + rcx + 4], 1
```

Full code of the assembly function can be found [here](). See also microbenchmarks integrated into [uarch-bench](https://github.com/travisdowns/uarch-bench/blob/0c4e467043d16dd955eaf09249a2f189f5ec2467/x86_methods.asm#L307).

```
Benchmark           Cycles   UOPS_RETIRED.RETIRE_SLOTS   UOPS_RETIRED.ALL
add [esp + ecx], 1  1.40     4.18                        4.20
```

### Example 4: unlamination

`picture`

```
// from the manual - unlaminated
add     ebx, DWORD [rsp + rdi * 4 - 4]
```

```
// full unlaminated
.loop:
add     DWORD [rsp + rdi * 4 - 4], 1
dec	rdi
jnz .loop
```

```
// no unlamination
.loop:
add     DWORD [rcx], 1
add	rcx, 4
dec	rdi
jnz .loop
```

### Additional links:
- stack-overflow answer
- Agner Fog
- Intel Optimization manual
