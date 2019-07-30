---
layout: post
title: How to get consitent results when benchmarking on Linux?
categories: [performance analysis, tools]
---

**Contents:**
* TOC
{:toc}

------
**Subscribe to my [mailing list]({{ page.url }}#mc_embed_signup) to get more updates from me!**

------

Lots of features in HW and SW are intended to increase performance. But some of them have non-deterministic behavior. In fact, today we will only talk about the features which are not permanently active. Since we have litle control over them, it makes sense to disable them to receive more consistent measurements and reduce the noise. Take turbo boost feature, for example: if we start two runs right after another on a "cold" processor, first run will possibly work for some time in overclocked mode. I.e. CPU will increase it's frequency to the extent permitted by thermal package ([TDP](https://en.wikipedia.org/wiki/Thermal_design_power)) and then go back somewhere around it's base frequency. However, the second run will operate on base frequency without entering the turbo mode. That's where variation in results might come from. 

So, ideally when doing benchmarking we try to disable all the potential sources of performance non-determinism in a system. This article is an attempt to bring all the tips together, provide examples and get instructions how to configure your machine properly.

It is important that you understand one thing before we start. If you use all the advices in this article it is not how your application will run in practice. If you want to compare two different versions of the same program you should use suggestions described above. If you want to get absolute numbers to understand how your app will behave in the field, you should not make any artificial tuning to the system, as the client might have default settings. 

All the info in the article is applicable if you do the measurements on the same system. For example, if you're a developer of performance critical application and you want to check if your change to the source code really did something good in terms of performance, then this article is exactly what you are looking for. Alternatively, advices in this article might be helpful if you want to compare performance of two snippets of code in a robust way.

I tried to sort the configuration settings in order of the impact on performance (according to my experience).

Other very informal and inspiring articles on the subject: [“Microbenchmarking calls for idealized conditions”](https://lemire.me/blog/2018/01/16/microbenchmarking-calls-for-idealized-conditions/) and ["Benchmarking tips"](https://llvm.org/docs/Benchmarking.html). There is some information about this written in Brendan Gregg's book ["Systems Performance: Enterprise and the Cloud"](https://amzn.to/2K3GHnG), see chapter 6.8 CPU Tuning.

### 1) Disable turboboost
Intel [Turbo Boost](https://en.wikipedia.org/wiki/Intel_Turbo_Boost) is a feature that automatically raises CPU operating frequency when demanding tasks are running.
```bash
echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
```
Also you might want to take a look at how it's done in [uarch-bench](https://github.com/travisdowns/uarch-bench/blob/master/uarch-bench.sh#L66).

### 2) Disable hyperthreading

Modern CPU cores are often made in the simultaneous multithreading ([SMT](https://en.wikipedia.org/wiki/Simultaneous_multithreading)) manner. It means that in one physical core you can have 2 threads of simultaneous execution. Typically, [architectural state](https://en.wikipedia.org/wiki/Architectural_state) is replicated but the execution resources (ALUs, caches, etc.) are not. That means that some other process that is schedulled on the sibling thread might steal cache space from the workload you are measuring.

The most robust way is to do this through BIOS as shown [here](https://www.pcmag.com/article/314585/how-to-disable-hyperthreading).
Additionally it can be done by turning down a sibling thread in each core.
```bash
echo 0 > /sys/devices/system/cpu/cpuX/online
```
The pair of cpu N can be found in `/sys/devices/system/cpu/cpuN/topology/thread_siblings_list` ([source](https://llvm.org/docs/Benchmarking.html#linux)).

### 3) Set scaling_governor to 'performance'

If we don't set the scaling governor policy to be `performance` kernel can decide that it's better to save power and throttle. Setting scaling_governor to 'performance' helps to avoid sub-nominal clocking. Here is the [documentation](https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt) about Linux CPU frequency governors.

Here is how we can set it for all the cores:
```bash
for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
  echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
done
```

### 4) Set cpu affinity
[Processor affinity](https://en.wikipedia.org/wiki/Processor_affinity) enables binding of a process to a certain CPU core(s). In Linux one can do this with [`taskset`](https://linux.die.net/man/1/taskset) tool.

Example:

```bash
# no affinity
$ perf stat -r 10 -- git status
        435,163622      task-clock (msec)         #    1,039 CPUs utilized            ( +-  3,62% )
               151      context-switches          #    0,347 K/sec                    ( +-  7,65% )
                10      cpu-migrations            #    0,023 K/sec                    ( +- 25,71% )
             5 171      page-faults               #    0,012 M/sec                    ( +-  0,02% )
       0,418973869 seconds time elapsed

# process is bound to the CPU0
$ perf stat -r 10 -- git status taskset -c 1
        420,948182      task-clock (msec)         #    0,985 CPUs utilized            ( +-  2,50% )
               102      context-switches          #    0,243 K/sec                    ( +-  6,00% )
                 0      cpu-migrations            #    0,000 K/sec                    ( +-100,00% )
             5 233      page-faults               #    0,012 M/sec                    ( +-  0,01% )
       0,427527231 seconds time elapsed 
```
Notice the number of cpu-migrations gets to `0`, i.e. process never leaves the core0.

Alternatively you can use https://github.com/lpechacek/cpuset to reserve cpus for just the program you are benchmarking. If using perf, leave at least 2 cores so that perf runs in one and your program in another ([source](https://llvm.org/docs/Benchmarking.html#linux)).

This will move all threads out of N1 and N2 (`-k on` means that even kernel threads are moved out):
```bash
cset shield -c N1,N2 -k on
```

This will run the command after -- in the isolated cpus:
```bash
cset shield --exec -- perf stat -r 10 <cmd>
```

### 5) Set process priority

In Linux one can increase process priority using `nice` tool (more about the tool [here](https://www.tecmint.com/set-linux-process-priority-using-nice-and-renice-commands)). By increasing priority process gets more CPU time and Linux scheduler favors it more in comparison with processes with normal priority.

For the previous exmaple, if we add `sudo nice -n -N`:
```bash
$ perf stat -r 10 -- sudo nice -n -5 taskset -c 1 git status
          0,003217      task-clock (msec)         #    0,000 CPUs utilized            ( +- 12,13% )
                 0      context-switches          #    0,000 K/sec                  
                 0      cpu-migrations            #    0,000 K/sec                  
                 0      page-faults               #    0,000 K/sec                  
       0,441287889 seconds time elapsed
```
Notice the number of context-switches gets to `0`, so the process received all the computation time uninterrupted.

### 6) Drop file system cache

Usually some area of main memory is assigned to cache the file system contents including various data. This reduces the need for application to go all the way down to the disk. One can drop current file system cache by running:

```bash
echo 3 > /proc/sys/vm/drop_caches
sync
```

Here is an example of file system cache importance:
```bash
# clean fs cache
$ echo 3 | sudo tee /proc/sys/vm/drop_caches && sync && time -p git status
real 2,57
# warmed fs cache
$ time -p git status
real 0,40
```

Alternatively you can make one 'dry' run just to warm the caches and exclude it from the measurements. I usually use it this dry run for validation purposes.

There is one more caveat. I do not recommend drop fs caches if you are analyzing performance (profiling) of the application. If you try to find the headroom in your app then it would be a bad baseline to pick. For example, [TMAM]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) will likely show your app is more memory bound than it would typically be. Much better would be to make a dry run first.

### 7) Disable address space randomization
> Address space layout randomization (ASLR) is a computer security technique involved in preventing exploitation of memory corruption vulnerabilities. In order to prevent an attacker from reliably jumping to, for example, a particular exploited function in memory, ASLR randomly arranges the address space positions of key data areas of a process, including the base of the executable and the positions of the stack, heap and libraries. ([source](https://en.wikipedia.org/wiki/Address_space_layout_randomization))

```bash
echo 0 > /proc/sys/kernel/randomize_va_space
```

### 8) Use statistical methods to process measurements
Another important way to reduce the noise is to use statistical methods. Yes, you are reading it right. You can get better comparison by doing better/more measurements.

My favorite article on this topic is ["Benchmarking: minimum vs average"](http://blog.kevmod.com/2016/06/benchmarking-minimum-vs-average/) where the author describes why for most of the benchmarking we better compare minimal values as opposed to averages:
> Personally, I understand benchmark results to be fairly right-skewed: you will frequently see benchmark results that are much slower than normal (several standard deviations out), but you will never see any that are much faster than normal.  When I see those happen, if I am taking a running average I will get annoyed since I feel like the results are then "messed up" (something that these numbers now give some formality to). So personally I use the minimum when I benchmark.

If you are doing microbenchmarking, then you might find usefull “delta” measurement approach - see this comment [here](https://lemire.me/blog/2018/01/16/microbenchmarking-calls-for-idealized-conditions/#comment-295373):

> The simple way to do this is if your test has a measurement loop and times the entire loop, run it for N iterations and 2N, and then use (run2 – run1)/N as the time. This cancels out all the fixed overhead, such as the clock/rdpmc call, the call to your benchmark method, any loop setup overhead.

**Final notes**

First 3 suggestions are HW related and sometimes it makes sense to configure dedicated machine for benchmarking. Big companies usually have a pool of machines that are specifically tuned for performance measurements.

Finally, I hope it is needless to say that no other process should be running at the time you're benchmarking. Even running 'top' on 12 core machine (typical Haswell Xeon server) will eat up CPU thermal package ([TDP](https://en.wikipedia.org/wiki/Thermal_design_power)) which might affect frequency of the core that is running the benchmark.
