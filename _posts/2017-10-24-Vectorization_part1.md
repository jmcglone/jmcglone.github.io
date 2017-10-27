---
layout: post
title: Vectorization part1. Intro.
tags: default
---

Recently I was working closely with analyzing different vectorization cases. So I decided to write a series of articles dedicated to this topic.

This is the first post in this series, so let me start with some introduction info. [Vectorization](https://stackoverflow.com/questions/1422149/what-is-vectorization) is a form of [SIMD](https://en.wikipedia.org/wiki/SIMD) which allows to crunch multiple values in one CPU instruction.

I know it is bad introduction when just links to wiki thrown everywhere around, so let me show you simple example [(godbolt)](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(j:1,source:'%23include+%3Cvector%3E%0Avoid+foo(+std::vector%3Cunsigned%3E%26+lhs,+std::vector%3Cunsigned%3E%26+rhs+)%0A%7B%0A++++for(+unsigned+i+%3D+0%3B+i+%3C+lhs.size()%3B+i%2B%2B+)%0A++++%7B%0A++++++++++++lhs%5Bi%5D+%3D+(+rhs%5Bi%5D+%2B+1+)+%3E%3E+1%3B++++++++%0A++++%7D%0A%7D'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),header:(),k:50,l:'4',m:100,n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang_trunk,filters:(b:'0',binary:'1',commentOnly:'0',demangle:'0',directives:'0',execute:'1',intel:'0',trim:'0'),libs:!(),options:'-O2+-march%3Dcore-avx2+-std%3Dc%2B%2B14+-fno-unroll-loops',source:1),l:'5',n:'0',o:'x86-64+clang+(trunk)+(Editor+%231,+Compiler+%231)',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4):

```cpp
#include <vector>
void foo( std::vector<unsigned>& lhs, std::vector<unsigned>& rhs )
{
    for( unsigned i = 0; i < lhs.size(); i++ )
    {
            lhs[i] = ( rhs[i] + 1 ) >> 1;
    }
}
```
Lets compile it with clang with options `-O2 -march=core-avx2 -std=c++14 -fno-unroll-loops`. I turned off loop unrolling to simplify the assembly and -march=core-avx2 tells compiler that generated code will be executed on a machine with avx2 support. Assembly generated contains:

Scalar version
```asm
mov edx, dword ptr [r9 + 4*rsi]         # loading rhs[i]
add edx, 1                              # rhs[i] + 1
shr edx                                 # (rhs[i] + 1) >> 1
mov dword ptr [rax + 4*rsi], edx        # store result to lhs
mov esi, edi
add edi, 1                              # incrementing i by 1
cmp rcx, rsi
ja <next iteration>
```
Vector version
```asm
vmovdqu ymm1, ymmword ptr [r9 + 4*rdi]  # loading 256 bits from rhs
vpsubd ymm1, ymm1, ymm0                 # ymm0 has all bits set, like +1
vpsrld ymm1, ymm1, 1                    # vector shift right.
vmovdqu ymmword ptr [rax + 4*rdi], ymm1 # storing result 
add rdi, 8                              # incrementing i by 8
cmp rsi, rdi
jne <next iteration>
```

So here you can see that vector version crunches 8 integers at a time (256 bits = 8 bytes). If you will analyze assembly carefull enough you will spot the runtime check which dispatch to those two versions. If there are not enough elements in the vector for choosing vector version, scalar version will be taken. Amount of instructions is smaller in vector version, although all vector instructions have [bigger latency](http://ithare.com/infographics-operation-costs-in-cpu-clock-cycles/<Paste>) than scalar counterparts.

Vector operations can give significant performance gains but they have quite many restrictions which we will cover later.
Historically, Intel has 3 instruction sets for vectorization: [MMX](https://en.wikipedia.org/wiki/MMX_(instruction_set)), [SSE](https://en.wikipedia.org/wiki/Streaming_SIMD_Extensions) and [AVX](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions).

Vector registers for those instruction sets are described [here](https://en.wikipedia.org/wiki/X86#/media/File:Table_of_x86_Registers_svg.svg).

In general, not only loops can be vectorized. There is also linear vectorizer (in llvm it is called [SLP vectorizer](https://llvm.org/docs/Vectorizers.html#slp-vectorizer)) which is searching for similar independent scalar instructions and tries to combine them.

To check vector capabilities of your CPU you can type `lscpu`. For my Intel Core i5-7300U filtered output is:
```
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc pni pclmulqdq ssse3 cx16 sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand hypervisor lahf_lm abm 3dnowprefetch rdseed clflushopt
```

For us the most interesting is that this CPU supports `sse4_2` and `avx` instruction sets.

That's all for now. In later articles I'm planing to cover following topics:
1. Vectorization intro (this article).
2. Vectorization warmup.
3. Checking compiler vectorization report.
4. Vectorization width.
5. Multiversioning by data dependency (DD).
6. Multiversioning by trip counts.
7. General tips for writing vectorizable code.
