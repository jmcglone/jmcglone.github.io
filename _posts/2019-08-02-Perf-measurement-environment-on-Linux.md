---
layout: post
title: How to get consistent results when benchmarking on Linux?
categories: [performance analysis, tools]
---

**Contents:**
* TOC
{:toc}

------
**Subscribe to my [mailing list]({{ page.url }}#mc_embed_signup) to get more updates from me!**

------

Lots of features in HW and SW are intended to increase performance. But some of them have non-deterministic behavior. In fact, today we will only talk about the features which are not permanently active. Since we have little control over them, it makes sense to disable them to receive more consistent measurements and reduce the noise. Take turbo boost feature, for example: if we start two runs, one right after another on a "cold" processor, first run will possibly work for some time in overclocked mode. I.e. CPU will increase its frequency to the extent permitted by thermal package ([TDP](https://en.wikipedia.org/wiki/Thermal_design_power)) and then go back somewhere around its base frequency. However, the second run will operate on base frequency without entering the turbo mode. That's where variation in results might come from. 

So, ideally when doing benchmarking we try to disable all the potential sources of performance non-determinism in a system. This article is an attempt to bring all the tips together, provide examples and give instructions how to configure your machine properly.

It is important that you understand one thing before we start. If you use all the advices in this article it is not how your application will run in practice. If you want to compare two different versions of the same program you should use suggestions described above. If you want to get absolute numbers to understand how your app will behave in the field, you should not make any artificial tuning to the system, as the client might have default settings. 

All the info in the article is applicable if you do the measurements on the same system. For example, if you're a developer of performance critical application and you want to check if your change to the source code really did something good in terms of performance, then this article is exactly what you are looking for. Alternatively, advices in this article might be helpful if you want to compare performance of two snippets of code in a robust way.

I tried to sort the configuration settings in order of the impact on performance (according to my experience).

Other very informal and inspiring articles on the subject: [“Microbenchmarking calls for idealized conditions”](https://lemire.me/blog/2018/01/16/microbenchmarking-calls-for-idealized-conditions/) and ["Benchmarking tips"](https://llvm.org/docs/Benchmarking.html). Also there is some information about how to configure Linux environment for performance written in Brendan Gregg's book ["Systems Performance: Enterprise and the Cloud"](https://amzn.to/2K3GHnG), see chapter 6.8 CPU Tuning.

### 1) Disable turboboost
Intel [Turbo Boost](https://en.wikipedia.org/wiki/Intel_Turbo_Boost) is a feature that automatically raises CPU operating frequency when demanding tasks are running. It can be permanently disabled in BIOS. Check [FAQ](https://www.intel.com/content/www/us/en/support/articles/000007359/processors/intel-core-processors.html) for more information. To disable turbo in Linux do:
```bash
# Intel
echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
# AMD
echo 0 > /sys/devices/system/cpu/cpufreq/boost
```
Also you might want to take a look at how it's done in [uarch-bench](https://github.com/travisdowns/uarch-bench/blob/master/uarch-bench.sh#L66).

Example (single-threaded workload running on Intel® Core™ i5-8259U):
```bash
# TurboBoost enabled
$ cat /sys/devices/system/cpu/intel_pstate/no_turbo
0
$ perf stat -e task-clock,cycles -- ./a.out 
      11984.691958      task-clock (msec)         #    1.000 CPUs utilized          
    32,427,294,227      cycles                    #    2.706 GHz                    
      11.989164338 seconds time elapsed
# TurboBoost disabled
$ echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
1
$ perf stat -e task-clock,cycles -- ./a.out 
      13055.200832      task-clock (msec)         #    0.993 CPUs utilized          
    29,946,969,255      cycles                    #    2.294 GHz                    
      13.142983989 seconds time elapsed
```

You can see the average frequency is much higher when TurboBoost is on.

### 2) Disable hyper threading

Modern CPU cores are often made in the simultaneous multithreading ([SMT](https://en.wikipedia.org/wiki/Simultaneous_multithreading)) manner. It means that in one physical core you can have 2 threads of simultaneous execution. Typically, [architectural state](https://en.wikipedia.org/wiki/Architectural_state) is replicated but the execution resources (ALUs, caches, etc.) are not. That means that some other process that is scheduled on the sibling thread might steal cache space from the workload you are measuring.

The most robust way is to do this through BIOS, for example as shown [here](https://www.pcmag.com/article/314585/how-to-disable-hyperthreading).
Additionally it can be done programmatically by turning down a sibling thread in each core:
```bash
echo 0 > /sys/devices/system/cpu/cpuX/online
```
The pair of cpu N can be found in `/sys/devices/system/cpu/cpuN/topology/thread_siblings_list` ([source](https://llvm.org/docs/Benchmarking.html#linux)).

The following example is just to show the effect of disabling HT. Remember, we are not talking about whether one should always disable HT. It is just for make our measurements more stable.
```bash
# all 4 HW threads enabled:
$ perf stat -r 10 -- git status
        663.659062      task-clock (msec)         #    1.399 CPUs utilized            ( +-  3.05% )
               160      context-switches          #    0.240 K/sec                    ( +-  5.48% )
                20      cpu-migrations            #    0.030 K/sec                    ( +- 14.61% )
           0.4744 +- 0.0198 seconds time elapsed  ( +-  4.17% )

# disable all the HW threads besides one:
$ echo 0 | sudo tee /sys/devices/system/cpu/cpu1/online
$ echo 0 | sudo tee /sys/devices/system/cpu/cpu2/online
$ echo 0 | sudo tee /sys/devices/system/cpu/cpu3/online
$ lscpu
...
CPU(s):               4
On-line CPU(s) list:  0
Off-line CPU(s) list: 1-3
...
$ perf stat -r 10 -- git status
        527.682446      task-clock (msec)         #    0.464 CPUs utilized            ( +-  2.45% )
               201      context-switches          #    0.381 K/sec                    ( +-  3.16% )
                 0      cpu-migrations            #    0.000 K/sec                  
            1.1370 +- 0.0308 seconds time elapsed  ( +-  2.71% )
```
As expected, no cpu-migrations, because only one HW thread available.

### 3) Set scaling_governor to 'performance'

If we don't set the scaling governor policy to be `performance` kernel can decide that it's better to save power and throttle. Setting scaling_governor to 'performance' helps to avoid sub-nominal clocking. Here is the [documentation](https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt) about Linux CPU frequency governors.

Here is how we can set it for all the cores:
```bash
for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
  echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done
```

### 4) Set cpu affinity
[Processor affinity](https://en.wikipedia.org/wiki/Processor_affinity) enables binding of a process to a certain CPU core(s). In Linux one can do this with [`taskset`](https://linux.die.net/man/1/taskset) tool.

Example:

```bash
# no affinity
$ perf stat -e context-switches,cpu-migrations -r 10 -- git status
               151      context-switches
                10      cpu-migrations
       0,418973869 seconds time elapsed

# process is bound to the CPU0
$ perf stat -r 10 -- taskset -c 0 git status 
               102      context-switches
                 0      cpu-migrations
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

For the previous example, if we add `sudo nice -n -N`:
```bash
$ perf stat -r 10 -- sudo nice -n -5 taskset -c 1 git status
          0,003217      task-clock (msec)         #    0,000 CPUs utilized            ( +- 12,13% )
                 0      context-switches          #    0,000 K/sec                  
                 0      cpu-migrations            #    0,000 K/sec                  
                 0      page-faults               #    0,000 K/sec                  
       0,441287889 seconds time elapsed
```
Notice the number of context-switches gets to `0`, so the process received all the computation time uninterrupted.

For OpenMP environment one can set `KMP_AFFINITY` (ICC) or `GOMP_AFFINITY` (GCC). This environment variable is used by OpenMP runtime to set thread affinity.

### 6) Drop file system cache

Usually some area of main memory is assigned to cache the file system contents including various data. This reduces the need for application to go all the way down to the disk. One can drop current file system cache by running:

```bash
echo 3 | sudo tee /proc/sys/vm/drop_caches
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

There is one more caveat. I do not recommend drop fs caches if you are analyzing performance (profiling) of the application. If you try to find the headroom in your app then it would be a bad baseline to pick. For example, [TMAM]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology) will likely show your app is more memory bound than it would typically be. Much better would be to make a dry run instead.

### 7) Disable address space randomization
> Address space layout randomization (ASLR) is a computer security technique involved in preventing exploitation of memory corruption vulnerabilities. In order to prevent an attacker from reliably jumping to, for example, a particular exploited function in memory, ASLR randomly arranges the address space positions of key data areas of a process, including the base of the executable and the positions of the stack, heap and libraries. ([source](https://en.wikipedia.org/wiki/Address_space_layout_randomization))

```bash
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
```

Disable ASLR on a per-process basis:
```bash
$ setarch -R ...
```

### 8) Use statistical methods to process measurements
Another important way to reduce the noise is to use statistical methods. Yes, you are reading it right. You can get better comparison by doing better/more measurements.

My favorite article on this topic is ["Benchmarking: minimum vs average"](http://blog.kevmod.com/2016/06/benchmarking-minimum-vs-average/) where the author describes why for most of the benchmarking we better compare minimal values as opposed to averages:
> Personally, I understand benchmark results to be fairly right-skewed: you will frequently see benchmark results that are much slower than normal (several standard deviations out), but you will never see any that are much faster than normal.  When I see those happen, if I am taking a running average I will get annoyed since I feel like the results are then "messed up" (something that these numbers now give some formality to). So personally I use the minimum when I benchmark.

If you are doing microbenchmarking, then you might find useful “delta” measurement approach - see this comment [here](https://lemire.me/blog/2018/01/16/microbenchmarking-calls-for-idealized-conditions/#comment-295373):

> The simple way to do this is if your test has a measurement loop and times the entire loop, run it for N iterations and 2N, and then use (run2 – run1)/N as the time. This cancels out all the fixed overhead, such as the clock/rdpmc call, the call to your benchmark method, any loop setup overhead.

### Other references

Papers:
* [STABILIZER: Statistically Sound Performance Evaluation](http://www.cs.umass.edu/~emery/pubs/stabilizer-asplos13.pdf).
* [Robust benchmarking in noisy environments](http://math.mit.edu/~edelman/publications/robust_benchmarking.pdf).
* [Producing Wrong Data Without Doing Anything Obviously Wrong!](http://users.cs.northwestern.edu/~robby/courses/322-2013-spring/mytkowicz-wrong-data.pdf).

Documentation:
* [How to Benchmark Code Execution Times on Intel® IA-32 and IA-64 Instruction Set Architectures](https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/ia-32-ia-64-benchmark-code-execution-paper.pdf).
* [Red Hat Enterprise Linux: Performance tuning guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/index).

Tools:
* Tool for setting up an environment for benchmarking: [temci](https://github.com/parttimenerd/temci).

### Final notes

First 3 suggestions are HW related and sometimes it makes sense to configure dedicated machine for benchmarking. Big companies usually have a pool of machines that are specifically tuned for performance measurements.

Finally, I hope it is needless to say that no other process should be running at the time you're benchmarking. Even running 'top' on 12 core machine (typical Haswell Xeon server) will eat up CPU thermal package ([TDP](https://en.wikipedia.org/wiki/Thermal_design_power)) which might affect frequency of the core that is running the benchmark.

### _UPD 09 Aug 2019_

There were lots of comments on [HN](https://news.ycombinator.com/item?id=20607042) and [Reddit](https://www.reddit.com/r/programming/comments/clptsx/how_to_get_consistent_results_when_benchmarking/evywea9/?context=3), here is what I found interesting:
1. There were debates about how to process the results of benchmarking: whether to take `min`, `avg`, `mean`, etc. The conclusion is that the strategy depends on a distribution of the results, and there is no substitute for **plotting** the data and taking a look at the distribution.
2. Besides TurboBoots one can also disable [Intel SpeedShift technology](https://www.anandtech.com/show/9751/examining-intel-skylake-speed-shift-more-responsive-processors).
3. Reducing the number of kernel background processes might reduce the noise. This can be accomplished by booting in `single-user/recovery` mode.
4. For even better accuracy one can put the benchmark body into the kernel module to guarantee the exclusive ownership of the CPU. More details in whitepaper: [How to Benchmark Code Execution Times on Intel® IA-32 and IA-64 Instruction Set Architectures](https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/ia-32-ia-64-benchmark-code-execution-paper.pdf). I have never tried this, and looks like it's not feasible for some of the big benchmarks and most of the it's overkill.
5. Most of the comments agreed that disabling [ASLR]({{ site.url }}/blog/2019/08/02/Perf-measurement-environment-on-Linux#7-disable-address-space-randomization) in majority of cases doesn't help to reduce the noise. Still I leave it in the post, just for the record.
