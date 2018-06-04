
### Runtime overhead of profiling

On the topic of runtime overhead in counting and profiling modes there is a [very good paper](https://openlab-archive-phases-iv-v.web.cern.ch/sites/openlab-archive-phases-iv-v.web.cern.ch/files/technical_documents/TheOverheadOfProfilingUsingPMUhardwareCounters.pdf) written by A. Nowak and G. Bitzes. They measured profiling overhead on a Xeon-based machine with 48 logical cores in different configurations: with disabled/enabled Hyper Threading, running tasks on all/several/one cores and collecting 1/4/8/16 different metrics. In my interpretation there is almost no runtime overhead (1-2%%) in counting mode and in sampling mode when you don't multiplex between different counters (with the caveat that you don't make the sampling frequency very high). However, if you'll try to collect more counters than the physical PMU counters available, you'll get performance hit of about 5-15% depending on the number of counters you want to collect and sampling frequency.

### PEBs

Capture beginning from Brendan's article, then from SDM B.3.3

### LBR

References:
  CERN - overhead of counting and sampling
  http://www.brendangregg.com/perf.html
  SDM v3 - chapters 18,19
  SDM v2 - instructions: RDPMC, RDTSC, RDTSCP, RDMSR, WRMSR
