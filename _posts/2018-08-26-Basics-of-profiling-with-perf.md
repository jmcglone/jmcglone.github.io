---
layout: post
title: Basics of profiling with perf.
categories: [beginner friendly, tools]
---

In this post I want to go back to the basic things of profiling with perf. I want to show what's happening when you type `perf record`. We all know that it somehow shows us the hotspots and where our application spend most of the time. That's great, but how it's doing it? Let's find out.

Before reading this post I suggest you to familiarize yourself with my two previous posts about [PMU counters and profiling basics]({{ site.url }}/blog/2018/06/01/PMU-counters-and-profiling-basics) and [Advanced profiling topics. PEBS and LBR]({{ site.url }}/blog/2018/06/08/Advanced-profiling-topics-PEBS-and-LBR). Especially with what is *counting* and *sampling*.

Suppose we have our application "a.out" which runs for approximately 2,5 seconds:
```
$ time -p ./a.out
real 2.67
user 2.48
```
Let's run `perf record` on it:
```bash
$ perf record ./a.out
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.110 MB perf.data (2451 samples) ] 
```
We have 2451 samples, that's 1 sample per millisecond. And that's a default behaviour: the perf tool defaults the frequency to 1000Hz, or 1000 samples/sec. It's also equivalent to run `perf record -F 1000`. Perf will stop our program 1000 times per second and see where the IP (instruction pointer) is. So, if we don't want that accuracy, we can choose a lower frequency:
```bash
$ perf record -F 100 ./a_out
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.026 MB perf.data (247 samples) ] // 1 sample per 10 milliseconds
```
But the interesting thing is that perf doesn't just stop your application after equal time intervals. If it would be so, there will be no difference for sampling on various events. Would we sample on cycles or instructions, there will be no difference, as perf will still stop the app after equal time intervals.

To understand what is it doing, we'll take a look inside perf.data. If we do so we will be able to see raw samples:
```bash
$ perf report -D
...
9253562614198937 0x4d18 [0x28]: PERF_RECORD_SAMPLE(IP, 0x2): 20531/20531: 0x40090b period: 32287405 addr: 0 
 ... thread: a_out:20531
 ...... dso: ./a_out

0x4d40 [0x28]: event: 9
.
. ... raw event: size 40 bytes
.  0000:  09 00 00 00 02 00 28 00 15 0a 40 00 00 00 00 00  ......(...@.....
.  0010:  33 50 00 00 33 50 00 00 21 99 1e f1 10 e0 20 00  3P..3P..!..... .
.  0020:  3c 65 ee 01 00 00 00 00                          <e......        
```

This is just one out of many samples collected during the whole runtime. First thing we'll take a look at is `0x40090b`. It is the instruction address on which this sample was collected. At the time when sample was captured, IP (instruction pointer) was set to this instruction. If we grep all the samples by this address:
```bash
$ perf report -D | grep 0x40090b -c
16
```
Which matches with what we see in `perf report`:
```
       │     0000000000400906 <foo.loop>:
       │     foo.loop():
   136 │400906:   mov    $0x0,%eax
    16 │40090b:   dec    %rsi
       │40090e: ↑ jne    400906 <foo.loop>
    22 │400910: ↓ jmpq   400a15 <foo.merge>
```

The second interesting thing is `period: 32287405` the number of occurrences of the event between two samples. Here things start to get interesting. So, between sample N-1 and N (that's presented) there were 32287405 cycles executed. Perf, when preparing for capturing next sample, set the value of one of the PMU counters to -3228740, then start incrementing it with every cycle (because we sample on cycles) and wait until it overflows (from -1 to 0). You can read more about this in my article about [PMU counters and profiling basics]({{ site.url }}/blog/2018/06/01/PMU-counters-and-profiling-basics).

Now, remember that by default we sample on cycles (equivalent to `perf record -e cycles`). With latest run we collected 247 samples. For simplicity let's assume average period for all samples is 32300000 events. Based on that, the number of cycles it took to execute this workload is: 247 * 32300000 = 7978100000 cycles.
If we compare this number with the number of counted cycles:
```bash
$ perf stat -e cycles ./a_out                                                                                                           
 Performance counter stats for './a_out':
        7805574851      cycles                                                      
       2,398101184 seconds time elapsed
```
We see that our calculated number 7978100000 is not that far off from the measured 7805574851.

We can do the same experiment with branch-misses:
```bash
$ perf record -F 1000 -e branch-misses ./a_out                                                                                                        
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.109 MB perf.data (2417 samples) ]
$ perfRep -D | grep period
9254712117721275 0x1a758 [0x28]: PERF_RECORD_SAMPLE(IP, 0x2): 21133/21133: 0x40051c period: 55754 addr: 0
9254712118718533 0x1a780 [0x28]: PERF_RECORD_SAMPLE(IP, 0x2): 21133/21133: 0x40051c period: 55804 addr: 0
$ perf stat -e branch-misses ./a_out
 Performance counter stats for './a_out':
         133366825      branch-misses                                               
       2,406486488 seconds time elapsed
```
Here we have 2417 (samples collected) * 55804 (period for each sample) = 134757418 (total branch-misses). Which again is not that far off from the measured value.

The opposite of setting frequency of collecting samples is to configure period:
```bash
$ perf record -e instructions -c 1000000 ./a_out
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.436 MB perf.data (13731 samples) ]
$ perf stat -e instructions ./a_out                                                                                                                      
 Performance counter stats for './a_out':
       13706955042      instructions                                                
       2,443039456 seconds time elapsed
```
Here we have 13731 (samples collected) * 1000000 (fixed number of retired instructions between samples) = 13731000000 (total number of instructions). Again the diviation from measured number of instructions retired (13706955042) is pretty small.

That's all for today. I'm preparing another beginner's post about basic terms in performance analysis, such as what's a retired instruction and how it's different from executed instruction. What is the difference between cycles and reference cycle. What is uop (micro-op), CPI/IPC, instruction latency and throughput. So, stay tuned!
