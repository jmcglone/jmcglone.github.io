---
layout: post
title: Estimating branch probability using Intel LBR feature.
categories: [tools, performance analysis]
---

**Contents:**
* TOC
{:toc}

------
**Subscribe to my [mailing list]({{ page.url }}#mc_embed_signup) to get more updates from me!**

------

Intel LBR (Last branch record) is one of my favorite CPU performance monitoring features. I previously wrote about one interesting use case for using it. Here is the [blog post]({{ site.url }}/blog/2019/04/03/Precise-timing-of-machine-code-with-Linux-perf) about how you can measure the number of cycles for a sequence of assembly instructions without fancy code instrumentation. Today I will write about another interesting use case for LBR feature that I use. In particular, having a code like:
```cpp
if (condition)
  // do something
else
  // do something else
```
It would be interesting to know how much time the condition was true and how much it was false. Why we might want to know that? Well that's one the key data we need to have for making better optimizing decisions. Knowing that condition is 99% of the time false, we better revert the condition and put the `else` branch first[^1]. We also might want to outline `true` branch in a separate function[^2].

In this article I will show one way to get this data without touching the source code. All you need to do is to have Linux environment with not too old Linux perf tool.

I should say that it's usually easier just to instrument the code (i.e. do printf logging of all the condition results) than to use sophisticated performance monitoring features. Manual code instrumentation will give a little bit better accuracy of the measurements, but usually the difference is negligible. The downside is that instrumentation gives more runtime performance overhead, whereas using LBR is almost free.

It may look like a clear win for instrumentation method, but there are certain scenarios when you have no such option. First scenario is when you don't have access to the source code of the application. We at Intel have such cases when people work under NDA on a customers application without having access to the source code of this application. Second scenario is when you have the sources, but you don't know how the software was built or you can't build it yourself.

If you are in any of the 2 cases described above, you've better read the article so you know all the options available.

### Recap on LBR

The underlying CPU feature that allows this to happen is called LBR(Last Branch Record). LBR feature is used to track control flow of the program. This feature uses MSRs (Model Specific Registers) to store history of last taken branches. Why we are so interested in branches? Well, because this is how we are able to determine the control flow of our program. Since we are interested in branches which are always the last instructions in a basic blocks and all instructions in the basic block are guaranteed to be executed once, we can only focus on branches. Using this control flow statistics we can determine which path of our program (chain of basic blocks) is the hottest. This chain of hot blocks is sometimes called a Hyper Block.

Traditionally LBR entry[^3] has two important components: `FROM_IP` and `TO_IP`, which are basically source address of the branch and destination address. If we collect long enough history of source-destination pairs, we will be able to unwind the control flow of our program. Just like a call stack! Sounds nice and simple, right? It's not that easy-peasy as it sounds, but keep on reading, with examples it will be more clear.

### Getting to a real world case

To demonstrate it's power I took the example from my [previous contest]({{ site.url }}/blog/2019/04/10/Performance-analysis-and-tuning-contest-2). This is [7zip benchmark](https://github.com/llvm-mirror/test-suite/tree/master/MultiSource/Benchmarks/7zip) which measures compression and decompression speed.

First of all let's run it through the [TMAM process]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) and see where we have the bottleneck:

```bash
$ ~/pmu-tools/toplev.py --core S0-C0 -l1 -v --no-desc taskset -c 0 ./7zip-benchmark b
S0-C0    FE             Frontend_Bound:          10.93 +-     0.00 % Slots below
S0-C0    BAD            Bad_Speculation:         41.98 +-     0.00 % Slots       <==
S0-C0    BE             Backend_Bound:           14.29 +-     0.00 % Slots      
S0-C0    RET            Retiring:                32.80 +-     0.00 % Slots below
```

All right, let's drill down on the next level:
```bash
$ ~/pmu-tools/toplev.py --core S0-C0 -l2 -v --no-desc taskset -c 0 ./7zip-benchmark b
S0-C0    FE             Frontend_Bound:                             13.74 +-     0.00 % Slots below
S0-C0    BAD            Bad_Speculation:                            39.32 +-     0.00 % Slots      
S0-C0    BE             Backend_Bound:                              15.61 +-     0.00 % Slots      
S0-C0    RET            Retiring:                                   31.28 +-     0.00 % Slots below
S0-C0    FE             Frontend_Bound.Frontend_Latency:             8.48 +-     0.00 % Slots below
S0-C0    FE             Frontend_Bound.Frontend_Bandwidth:           5.28 +-     0.00 % Slots below
S0-C0    BAD            Bad_Speculation.Branch_Mispredicts:         39.29 +-     0.00 % Slots       <==
S0-C0    BAD            Bad_Speculation.Machine_Clears:              0.03 +-     0.00 % Slots below
S0-C0    BE/Mem         Backend_Bound.Memory_Bound:                  7.14 +-     0.00 % Slots below
S0-C0    BE/Core        Backend_Bound.Core_Bound:                    8.47 +-     0.00 % Slots below
S0-C0    RET            Retiring.Base:                              31.15 +-     0.00 % Slots below
S0-C0    RET            Retiring.Microcode_Sequencer:                0.12 +-     0.00 % Slots below
```

We see that there is a lot of branch mispredictions in this application. We also can confirm it with collecting perf statistics:

```bash
$ perf stat ./7zip-benchmark b
        3368666620      branches                  #  362,573 M/sec                  
         432791583      branch-misses             #   12,85% of all branches
```

Next step is to locate the exact place in the code where the most of branch mispredictions happen. Please refer to my article about [Top-Down performance analysis methodology]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) for more explanations on why we are doing this. I'm using `BR_MISP_RETIRED.ALL_BRANCHES_PS` precise event (PEBS) to locate exact instruction where issue triggers.

```bash
$ perf record -e cpu/event=0xc5,umask=0x0,name=BR_MISP_RETIRED.ALL_BRANCHES_PS/ppp ./7zip-benchmark b
 
 % of samples     address        instruction

    0.00 : ┌─┬───> 4edab0:       mov    ecx,ecx
    0.00 : │ │     4edab2:       movzx  eax,WORD PTR [r9+rcx*2]
    4.36 : │ │     4edab7:       cmp    ebp,0xffffff
    0.66 : │ │ ┌── 4edabd:       ja     4edad0 
    0.00 : │ │ │   4edabf:       shl    ebp,0x8
    0.00 : │ │ │   4edac2:       shl    r10d,0x8
    0.00 : │ │ │   4edac6:       movzx  edx,BYTE PTR [r8]
    0.00 : │ │ │   4edaca:       inc    r8
    0.00 : │ │ │   4edacd:       or     r10d,edx
    0.00 : │ │ └─> 4edad0:       mov    edx,ebp
    0.00 : │ │     4edad2:       shr    ebp,0xb
    0.00 : │ │     4edad5:       imul   ebp,eax
    0.00 : │ │     4edad8:       mov    esi,r10d
!-> 8.77 : │ │     4edadb:       sub    esi,ebp
!-> 8.74 : │ │ ┌── 4edadd:       jae    4edb00            <== THIS IS OUR BRANCH
    0.00 : │ │ │   4edadf:       mov    edx,0x800         <== TRUE CASE
    0.00 : │ │ │   4edae4:       sub    edx,eax
    0.00 : │ │ │   4edae6:       shr    edx,0x5
    0.00 : │ │ │   4edae9:       add    edx,eax
    0.00 : │ │ │   4edaeb:       mov    WORD PTR [r9+rcx*2],dx
    0.00 : │ │ │   4edaf0:       lea    ecx,[rcx+rcx*1]
    2.03 : │ │ │   4edaf3:       cmp    ecx,0x100
    0.47 : │ └──── 4edaf9:       jb     4edab0 
    0.00 : │   │   4edafb:       jmp    4edb26 
    0.00 : │   │   4edafd:       nop    DWORD PTR [rax]
    0.00 : │   └─> 4edb00:       sub    edx,ebp           <== FALSE CASE
    0.00 : │       4edb02:       mov    edi,eax
    0.00 : │       4edb04:       shr    edi,0x5
    0.00 : │       4edb07:       sub    eax,edi
    0.00 : │       4edb09:       mov    rdi,QWORD PTR [rsp-0x68]
    0.00 : │       4edb0e:       mov    WORD PTR [r9+rcx*2],ax
    0.00 : │       4edb13:       lea    ecx,[rcx+rcx*1]
    0.00 : │       4edb16:       add    ecx,0x1
    0.00 : │       4edb19:       mov    ebp,edx
    0.00 : │       4edb1b:       mov    r10d,esi
    2.12 : │       4edb1e:       cmp    ecx,0x100
    0.40 : └────── 4edb24:       jb     4edab0 
```

Okay, now we know which branch is causing us performance inefficiencies. The code snippet that corresponds to the assembly above is the following (it doesn't matter much what exactly is going on in the code):
```cpp
do {
  ttt = *(prob + symbol);
  if (range < ((UInt32)1 << 24)) {
    range <<= 8;
    code = (code << 8) | (*buf++);
  };
  bound = (range >> 11) * ttt;
  if (code < bound) {               // <== This is mispredicted branch
    range = bound;
    *(prob + symbol) = (UInt16)(ttt + (((1 << 11) - ttt) >> 5));
    symbol = (symbol + symbol);
  } else {
    range -= bound;
    code -= bound;
    *(prob + symbol) = (UInt16)(ttt - (ttt >> 5));
    symbol = (symbol + symbol) + 1; 
  }
} while (symbol < 0x100);
```

### Collecting branch statistics

Let's profile the workload with collecting branch stacks with every sample. You can refer to the same procedure I did in one of my previous posts: [Precise timing of machine code with Linux perf]({{ site.url }}/blog/2019/04/03/Precise-timing-of-machine-code-with-Linux-perf).
```bash
$ ~/perf record -b -e cycles ./7zip-benchmark b
[ perf record: Woken up 68 times to write data ]
[ perf record: Captured and wrote 17.205 MB perf.data (22089 samples) ]
```
Now let's dump the contents of collected branch stacks:
```bash
$ ~/perf script -F brstack &> dump.txt
```
If we look inside the `dump.txt` (it might be big) we will see something like:
```
0x4edabd/0x4edad0/P/-/-/2  0x4edaf9/0x4edab0/P/-/-/29  0x4edabd/0x4edad0/P/-/-/2  0x4edb24/0x4edab0/P/-/-/23  0x4edadd/0x4edb00/M/-/-/4  0x4edabd/0x4edad0/P/-/-/2  0x4edb24/0x4edab0/P/-/-/24  0x4edadd/0x4edb00/M/-/-/4  0x4edabd/0x4edad0/P/-/-/2  0x4edb24/0x4edab0/P/-/-/23  0x4edadd/0x4edb00/M/-/-/1  0x4edabd/0x4edad0/P/-/-/1  0x4edb24/0x4edab0/P/-/-/3  0x4edadd/0x4edb00/P/-/-/1  0x4edabd/0x4edad0/P/-/-/1  0x4edb24/0x4edab0/P/-/-/3  0x4edadd/0x4edb00/P/-/-/1  0x4edabd/0x4edad0/P/-/-/1  0x4edb24/0x4edab0/P/-/-/3  0x4edadd/0x4edb00/P/-/-/4  0x4edabd/0x4edad0/P/-/-/42  0x4edd16/0x4ed9f0/P/-/-/13  0x4edca1/0x4edcd7/P/-/-/17  0x4edc5f/0x4edc72/P/-/-/2  0x4edc9f/0x4edc40/P/-/-/4  0x4edc5f/0x4edc72/P/-/-/3  0x4edc9f/0x4edc40/P/-/-/3  0x4edc5f/0x4edc72/P/-/-/2  0x4edc9f/0x4edc40/P/-/-/9  0x4edc5f/0x4edc72/P/-/-/4  0x4edc9f/0x4edc40/P/-/-/29  0x4edc5f/0x4edc72/P/-/-/2
```
**This is one branch stack** that consists of 32 LBR entries. Each entry has `FROM` and `TO` addresses, predicted flag (`M`/`P`) and number of cycles (number in the last position of each entry). Format of the entry is described in the perf script [specification](http://man7.org/linux/man-pages/man1/perf-script.1.html). 

For the purpose of calculating how much time certain branch was taken we would be interested in FROM/TO pairs. This is an easy case since we need just to grep our dump with `FROM` as address of our branch instruction and `TO` as destination of our branch:

```bash
# How much times the branch was taken:
$ grep "0x4edadd/0x4edb00" dump.txt -o | wc -l
20038
```

Knowing the opposite might be a little bit tricky since not taken branches are not logged by LBR mechanism. But in this case it's possible to do. When `0x4edadd` branch is not taken, either `0x4edaf9` or `0x4edafb` branches would be taken.

```bash
# How much times the branch was NOT taken:
$ grep "0x4edaf9/0x4edab0" dump.txt -o | wc -l
17246
$ grep "0x4edafb/0x4edb26" dump.txt -o | wc -l
2475
Total: 17246 + 2475 = 19721
```

Now we can also calculate how often this condition was true or false:
```
Ratio: F = 20038 / 39759 = 50.3%
Ratio: T = 19721 / 39759 = 49.6%
```
I was really surprised with such numbers so I decided to manually instrument the code and log all the branch outcomes in this place of the benchmark:
```
Ratio: F = 56953776 / 114025796 = 49.9%
Ratio: T = 57072020 / 114025796 = 50.0%
```

And indeed this branch has 50% probability of being true.

### Analyzing virtual calls and jump tables

This technique is especially useful for determining the outcome for indirect branches and indirect calls. Indirect branches usually appear from a converting switch statement to a jump table. Indirect call usually can be seen in C++ code and appear from a virtual call. 

Let's look at the example of collecting statistics which virtual function has the biggest call count. We have classes `B`, `C` and `D` all derived from `A`. All three classes implement public interface `foo()` (complete sources on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/BranchProbabilitiesUsingLBR)):

```cpp
int main() {
  const int min = 0;
  const int max = 9;
  std::default_random_engine generator;
  std::uniform_int_distribution<int> distribution(min,max);

  B b;
  C c;
  D d;
  A* a = nullptr;
  for (int i = 0; i < 100000000; i++) {
    int random_int = distribution(generator);
    if (random_int == 0)
      a = &b; // 10% probability
    else if (random_int < 4)
      a = &c; // 30% probability
    else 
      a = &d; // 60% probability
    a->foo(random_int);
  }

  return 0;
}
```

Let's make sure we have an indirect call inside the loop:

```bash
$ perf record ./a.out
$ perf annotate --stdio -M intel -l main
    0.00 : ┌─> 4005f0:       lea    rdx,[rsp+0x10]
    0.00 : │   4005f5:       mov    rsi,rsp
    4.63 : │   4005f8:       mov    rdi,rdx
    7.16 : │   4005fb:       call   400720 std::uniform_int_distribution<int>::operator()
    0.00 : │   400600:       test   eax,eax
    7.41 : │   400602:       lea    rdi,[rsp+0x20]
    0.00 : │   400607:       je     400613 <main+0x73>
    0.19 : │   400609:       cmp    eax,0x3
    0.00 : │   40060c:       mov    rdi,r12
   12.86 : │   40060f:       cmovg  rdi,rbp
   28.33 : │   400613:       mov    rdx,QWORD PTR [rdi]
    0.00 : │   400616:       mov    esi,eax
   32.38 : │   400618:       call   QWORD PTR [rdx]       <== this is our virtual call
    0.00 : │   40061a:       sub    ebx,0x1
    7.03 : └─  40061d:       jne    4005f0 <main+0x50>
```

I did all the steps I made while analyzing first example in the article (see above) and collected call counts:

```bash
# call count for B::foo()
$ grep "0x400618/0x4008c0" dump.txt -o | wc -l
6041
# call count for C::foo()
$ grep "0x400618/0x4008d0" dump.txt -o | wc -l
18219
# call count for D::foo():
$ grep "0x400618/0x4008e0" dump.txt -o | wc -l
33914

# total call count: 58174
```

Here is what we get if we calculate the call frequencies:

```
B::foo(): 10.3%
C::foo(): 31.3%
D::foo(): 58.3%
```

You see, results are quite accurate and not that far off from what we expected.

### Other references

I encourage you to take a look at Andi Kleen’s articles on lwn.net: [part1](https://lwn.net/Articles/680985/), [part2](https://lwn.net/Articles/680996/). There he describes other important uses cases for LBR feature:

1. Collecting basic block frequencies
2. Detecting "super blocks"[^4].
3. Calculating branch mispredictions.
4. Capturing call graph.

------
[^1]: See example [here]({{ site.url }}/blog/2019/03/27/Machine-code-layout-optimizatoins#basic-block-placement).
[^2]: See example [here]({{ site.url }}/blog/2019/03/27/Machine-code-layout-optimizatoins#function-splitting).
[^3]: See https://software.intel.com/sites/default/files/managed/7c/f1/253669-sdm-vol-3b.pdf, chapter "17.4.8 LBR Stack".
[^4]: Super blocks are also sometimes called Hyper Blocks. It is a sequence of hot basic blocks that are not necessary laid out in sequential physical order, but often execute sequentially (i.e. one basic block is a successor of another basic block).
