---
layout: post
title: Using denormal values is slow. How to detect it?
categories: [tuning]
---

**Contents:**
* TOC
{:toc}

In this short post I want to show the example how denormal values that you can use (unintentionally) in your calculations might slow down your code. And especially how to detect it using [performance counters]({{ site.url }}/blog/2018/06/01/PMU-counters-and-profiling-basics).If you're not familiar with what denormal floats it's now the good time to [read](https://en.wikipedia.org/wiki/Denormal_number) it.

*Disclaimer: In this post I don't touch the topic of how to disable denormal floats at the code/compiler level. There is lots of information in the web.*

### Example

I put a division of two floats in a tight loop:

```cpp
int bench(volatile float x, volatile float y)
{
  float sum = 0.0f;
  for (int i = 0; i < 100000000; i++)
  {
    sum = x / y;
    DoNotOptimize(sum);
    sum = 0.0f;
  }
  return (int)sum;
}
```

In first case I pass 2 normal floats and in second 2 denormal floats as arguments. Example of a denormal float would be 0xF and 0x7. Example of normal float would be 0.1f and 0.2f. You can check their binary representations and compare. 

Full code can be found on my [github](https://github.com/dendibakh/dendibakh.github.io/tree/master/_posts/code/Denormals).

I built everything with `gcc -O1` and checked that we have a loop with division inside:
```asm
  4009df:	c5 fa 10 4c 24 fc    	vmovss xmm1,DWORD PTR [rsp-0x4]
  4009e5:	c5 fa 10 44 24 f8    	vmovss xmm0,DWORD PTR [rsp-0x8]
  4009eb:	c5 f2 5e d0          	vdivss xmm2,xmm1,xmm0
  4009ef:	c5 f9 7e d2          	vmovd  edx,xmm2
  4009f3:	83 e8 01             	sub    eax,0x1
  4009f6:	75 e7                	jne    4009df <_Z5benchff+0x11>
```

### Measurements

Normal floats:
```
$ perf stat -e cycles,cpu/event=0xc2,umask=0x2,name=UOPS_RETIRED.RETIRE_SLOTS/,cpu/event=0xca,umask=0x1e,cmask=0x1,name=FP_ASSIST.ANY/,cpu/event=0x79,umask=0x30,name=IDQ.MS_UOPS/ ./a.out norm

x isnormal: yes
y isnormal: yes

 Performance counter stats for './a.out norm':

         303078534      cycles                                                      
         502937703      UOPS_RETIRED.RETIRE_SLOTS                                   
                 0      FP_ASSIST.ANY                                               
            808676      IDQ.MS_UOPS                                                 

       0,081426690 seconds time elapsed
```

Denormal floats:
```
$ perf stat -e cycles,cpu/event=0xc2,umask=0x2,name=UOPS_RETIRED.RETIRE_SLOTS/,cpu/event=0xca,umask=0x1e,cmask=0x1,name=FP_ASSIST.ANY/,cpu/event=0x79,umask=0x30,name=IDQ.MS_UOPS/ ./a.out denorm

x isnormal: no
y isnormal: no

 Performance counter stats for './a.out denorm':

       15720344436      cycles                                                      
        4721230495      UOPS_RETIRED.RETIRE_SLOTS                                   
         100000000      FP_ASSIST.ANY                                               
        4307771477      IDQ.MS_UOPS                                                 

       4,154192419 seconds time elapsed
```

### Explanation

First observation is that divisions on denormal values is `50` times slower. No surprise, but lets understand why that happens.

Whenever CPU see that it's processing denormal value it asks for a microcode assist. Microcode Sequencer (MS) then will feed the pipeline with lots of [UOPs]({{ site.url }}/blog/2018/09/04/Performance-Analysis-Vocabulary) for handling that scenario. We can see that in the slow case we have exactly `100000000` fp assits from MS and in normal case it's zero. Also we can spot that in the slow case major part of UOPs comes from MS.

So, here are your tools in detecting situations when your programm starts doing calculation with denormal values.

