---
layout: post
title: Developing intuition when working with performance counters.
categories: [performance analysis]
---

For developers that track performance of their application it is a usual thing that we might see performance degradations and gains during development life cycle. And once we see such perf changes, collecting basic performance metrics for both versions and comparing them is a perfectly valid way to proceed. However, there are road blocks along the way, of which you've better know in advance, so keep on reading.

**Example.** Suppose we have two version of the same application. Let's call them `A` and `B`. Say, there was some source code change which yield performance degradation of 5%. I.e. the binary A performs 5% better than binary B. We collected performance counters and there are no particular outliers besides the difference in LLC cache-misses:
```
<binary A - better>
1,000,000      LLC-load-misses
<binary B>
1,200,000      LLC-load-misses
```

This is so tempting to connect 20% increased number of LLC misses with 5% performance drop and say we are done. But it might be that this difference is misleading you!

To know if this is the case we need to look at the absolute numbers and do a simple math. We measured the running time and learned that:

```
<binary A>
    34,533,881,975   cycles
      14.599443021   seconds time elapsed
<binary B>
    36,557,520,561   cycles
      15.320553207   seconds time elapsed
```

We have the difference in ~2B cycles. Let's now check if additional `200,000` LLC misses can contribute to this performance drop. If we assume that LLC miss cost us around 100 cycles, then we will have additional penalty of only 200,000 * 100 = 20M cycles. Comparing it to 2B cycles additional 200,000 LLC misses contribute only to 1% of the performance drop, i.e. 5% * 0,01 = 0.05% running time degradation. It's just a noise.

Besides checking absolute numbers there is another way to check this. 

The more reliable way to check it would be to use [Top-Down analysis]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology). If you haven't read this article before I would recommend to do it now. TLDR; this analysis methodology aims at estimating how much certain type of event (like L3 cache miss) contributes to overall performance. Take a look at the article I just mentioned to see examples.

In particular we might look at the `Memory_Bound` metric:
```bash
$ ~/pmu-tools/toplev.py --core S0-C0 -v --no-desc taskset -c 0 --nodes Memory_Bound <your_app>
```

Often there are pairs of performance counters that will not only tell you the absolute number of certain event happened, but how much penalty cycles were taken because of events of this type. In our case we would be looking at `CYCLE_ACTIVITY.STALLS_L3_MISS` counter. According to [Intel manual]() it tells us "Cycles while L3 cache miss demand load is outstanding".

Here is the [example]({{ site.url }}/blog/2019/02/09/Top-Down-performance-analysis-methodology#fixing-the-issue) where the number of L3 cache-misses is significant and does matter:

```
<binary A>
       32226253316      cycles                                                      
       19764641315      CYCLE_ACTIVITY.STALLS_L3_MISS 
          71370594      MEM_LOAD_RETIRED.L3_MISS 
       8,533080624 seconds time elapsed
<binary B - better>
       24621931288      cycles                                                      
        2069238765      CYCLE_ACTIVITY.STALLS_L3_MISS                                   
           8889566      MEM_LOAD_RETIRED.L3_MISS                                    
       6,498080824 seconds time elapsed
```

That's all. My general advice when working with performance counters would be to always **look at the absolute numbers**, not just the ratio between different metrics. And ask yourself, **can this difference contribute to the performance change that you see**?
