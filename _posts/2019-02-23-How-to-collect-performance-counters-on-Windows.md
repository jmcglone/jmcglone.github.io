---
layout: post
title: How to collect CPU performance counters on Windows?
categories: [tools, performance analysis, windows]
---

**Contents:**
* TOC
{:toc}

I was asked a couple of times by my subscribers how to do microarchitectural analysis on Windows? To be honest I never had that problem before. Guess why? Because I work at Intel and of course I have the license to use [Intel® VTune™ Amplifier](https://software.intel.com/en-us/vtune). I can't fully feel the pain of the people who are doing performance related work on windows and don't have access to Vtune or [AMD CodeAnalyst](https://en.wikipedia.org/wiki/AMD_CodeAnalyst). Since it wasn't my problem I didn't make any efforts towards it. Finally I was browsing through [Bartek's coding blog](https://www.bfilipek.com/) and found the article [Curious case of branch performance](https://www.bfilipek.com/2017/05/curius-case-of-branch-performance.html). To me that seemed like a case that can be easily proven just by running `perf stat` if we were on Linux. But since we are on Windows... it's not that simple.

In this article I want to present one way how you can collect [PMU counters]({{ site.url }}/blog/2018/06/01/PMU-counters-and-profiling-basics) without Intel® VTune™ Amplifier. I took almost all the info from Bruce Dawson's [blog](https://randomascii.wordpress.com/). He wrote and [article](https://randomascii.wordpress.com/2016/11/27/cpu-performance-counters-on-windows/) which I want to expand and make it more of a step-by-step process. So, all the credit goes to Bruce here, because i didn't invent this. If you want to try it yourself, I suggest you first reproduce the example described in Bruce's article (link to [github](https://github.com/google/UIforETW/tree/master/LabScripts/ETWPMCDemo) with sources and scripts).

Take all that is written in my article with a grain of salt though. I'm not a Windows developer and I'm not spending my time doing performance analysis on Windows. This is just one way to collect [PMU counters]({{ site.url }}/blog/2018/06/01/PMU-counters-and-profiling-basics), but there might be others, more simple and robust. In the end you can purchase [Intel® VTune™ Amplifier](https://software.intel.com/en-us/vtune) which by the way can be quite expensive. But I want to say upfront, that there are no real alternatives to Vtune if you are going to do serious performance analysis and tuning on Windows (this is not an advertisement).

### What tools you will need?

1. __xperf__. You need to install [Windows Performance Toolkit](https://docs.microsoft.com/en-us/windows-hardware/test/wpt/) which is a part of [Windows Assessment and Deployment Kit (Windows ADK)](https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install). For me xperf was automatically added to PATH.

2. __tracelog__. Follow [instructions](https://docs.microsoft.com/ru-ru/windows-hardware/drivers/devtest/tracelog) to get this tool. You need the following components to be installed:
  * Windows Driver Kit
  * Visual Studio
  * Windows SDK
  
Tracelog wasn't added to my PATH, but I was able to find it under the following path: `"C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0\x64\"`. It might differ for you.

Installing all those kits require some time, so please be patient.

### Using tracelog and xperf for collecting traces

I will use the example that Bruce created, partially repeating his actions. Here is how you can obtain traces (with branch mispediction information) from your application using the tools mentioned above (should be run as Administrator):

```
tracelog.exe -start counters -f counters.etl -eflag CSWITCH+PROC_THREAD+LOADER -PMC BranchMispredictions,BranchInstructions:CSWITCH
<your app>
xperf -stop counters
xperf -merge counters.etl pmc_counters_merged.etl
xperf -i pmc_counters_merged.etl -o pmc_counters.txt
```

If we will look inside `pmc_counters.txt` we can observe the whole trace in the text format. There is a lot of interesting can be extracted from them, but lets concentrate on two things:
1. Pmc ([performance monitoring counter](https://en.wikipedia.org/wiki/Hardware_performance_counter)) event:

```
                    Pmc,  TimeStamp,   ThreadID, BranchMispredictions, BranchInstructions
```

2. CSwitch ([context switch](https://en.wikipedia.org/wiki/Context_switch)) event:

```
                CSwitch,  TimeStamp, New Process Name ( PID),    New TID, NPri, NQnt, TmSinceLast, WaitTime, Old Process Name ( PID),    Old TID, OPri, OQnt,        OldState,      Wait Reason, Swapable, InSwitchTime, CPU, IdealProc,  OldRemQnt, NewPriDecr, PrevCState, OldThrdBamQosLevel, NewThrdBamQosLevel
```

Here is some piece of the actual trace:

```
                    Pmc,     214810,       5956, 1101534, 44324578
                CSwitch,     214810, ConditionalCount.exe (14224),       5956,    9,   -1,           6,        0,           System (   4),        560,   12,   -1,         Waiting,          WrQueue,  NonSwap,      6,   1,   3,   84017152,    0,    0,   Important,   Important
                    Pmc,     214821,      14460, 1101713, 44326484
                CSwitch,     214821,        csrss.exe ( 888),      14460,   14,   -1,       73556,        5, ConditionalCount.exe (14224),       5956,    9,   -1,         Waiting,       WrLpcReply, Swapable,     11,   1,   3,   77701120,    0,    0,   Important,   Important
```

Note, that for each CSwitch event there is corresponding Pmc event. We can see that they come with the same timestamp. In this snippet of trace, there was a context switch from our process (which is ConditionalCount.exe) to another process (csrss.exe). We can see this by looking at `Old Process Name ( PID)` of CSwitch event with timestamp `214821`. So, there was some period of time in which ConditionalCount.exe has been executing on CPU (between timestamps `214821` and `214810`). 

The value for the `BranchMispredictions` counter is constantly growing. We can calculate how much branch mispredictions were there for this period of time, by substracting values from the 2 Pmc event. For this snippet there were `1101713 - 1101534 = 179` branch mispredictions. By summing up together all the deltas we can calculate total number of branch mispredictions for the whole runtime of the app.

Pro tip: if you see the numbers that are different from what you expected, I suggest you try to run the same benchmark on Linux using 'perf stat <your binary>' command. You can find lots of articles how to do that on my blog. The other way to is to dump the assembly and check that there is the code you expect. It might be the case that compiler did something smart and eliminated the code that you want to benchmark.

### Parsing traces with python script

To parse the trace and extract the information Bruce wrote the [script](https://github.com/google/UIforETW/blob/master/LabScripts/ETWPMCDemo/etwpmc_parser.py). This script actually extracts the PMC values for the processes that we are interested in (2 argument):

```
python.exe etwpmc_parser.py pmc_counters.txt <your app>
```

Here is the output that I received on my machine (Win 10, Intel(R) Core(TM) i5-7300U).

```
                  Process name:  branch misp rate, [br_misp, total branc]
  ConditionalCount.exe (14224):            21.91%, [109184040, 498250335], 3690 context switches, time: 1093072
  ConditionalCount.exe (10964):             0.07%, [369677, 496453009],    761 context switches,  time: 257492
```

Vtune shows similar results.

### What other counters we can collect?

```
> tracelog.exe -profilesources Help
Id  Name                        Interval  Min      Max
--------------------------------------------------------------
  0 Timer                          10000  1221    1000000
  2 TotalIssues                    65536  4096 2147483647
  6 BranchInstructions             65536  4096 2147483647
 10 CacheMisses                    65536  4096 2147483647
 11 BranchMispredictions           65536  4096 2147483647
 19 TotalCycles                    65536  4096 2147483647
 25 UnhaltedCoreCycles             65536  4096 2147483647
 26 InstructionRetired             65536  4096 2147483647
 27 UnhaltedReferenceCycles        65536  4096 2147483647
 28 LLCReference                   65536  4096 2147483647
 29 LLCMisses                      65536  4096 2147483647
 30 BranchInstructionRetired       65536  4096 2147483647
 31 BranchMispredictsRetired       65536  4096 2147483647
```

### Conclusion

This goes anywhere near to what Linux perf or Vtune are able to do. The number of counters is limited and this is only does counting, no sampling (see the difference between counting and sampling [here]({{ site.url }}/blog/2018/06/01/PMU-counters-and-profiling-basics) ). That's all true, but at least you can do some initial performance analysis.

Second thing is that if you want to collect different PMC than branch misprediction you need to modify not just the tracelog command but also the python script that parses traces.

If you know any other/better way to do that, let me know. I would definitely want to hear that.

I hope that also helps people that are on Windows and do want to participate in my [contest]({{ site.url }}/blog/2019/02/02/Performance-optimization-contest). If so, **make sure to subscribe** using the form at the bottom of the page.
