One way of analyzing performance of an application is instrumenting it and run. Theoretically, with this approach we can profile our application right within the application itself. However, it is not really the desired way to do it, because it is very time consuming, require recompilation each time we want to collect new metrics, and brings runtime overhead and noise in the measurements.

We all know that, no surprise. The other way is to use profiling tools like perf and Vtune that will collect statistics without instrumenting the binary. I'm using those profiling tools very extensively but understanding how they work came to me not so long time ago. In this article I will try to uncover some basic principles of how those tools work.

### CPU mental model and simplest PMU counter

In a really simplified view our processor looks like this:

![](/img/posts/PMU_counters/mental_model.jpg){: .center-image }

Just for a moment let's imagine that it is how things physically lay out on a die.

There is a clock generator that sends pulses to every piece of the system to make everything moving to the next stage. This is called a cycle. If we add just a little bit of silicon and connect it to the pulse generator we can count a number of cycles. 

![](/img/posts/PMU_counters/simplest_counter.jpg){: .center-image }

This is the simplest possible counter. It is called a `counter` for a reason of course, it's purpose is to count certain events. Every time a new pulse comes out our counter is incremented by 1. In reality counter is just yet another HW registers. You can sample it from time to time to know how many clockticks passed.

Counting cycles is great, however, that's not super helpful if we want to collect statistics about, say, L1 cache or our execution units.

### So, how about counting more?

We can connect our counter to other units just by laying out the wires from every element we interested in to our counter.

![](/img/posts/PMU_counters/many_connections_to_one_counter.jpg){: .center-image }

Notice, that I added one more element to the figure, it's a configuration register. Because now we need a way to tell "now I want to sneak into L1" and "now I want to return back to counting cycles". 

I should also point out that this is not everything that is needed for our beautiful counters to work. We also need special assembly instructions to read the value from the counter and write to the config register. In order for those instructions to work we need physical paths from execution units to all the counters to be able to pull the values from it.

With only one counter it's possible to count only one thing at a time. Ough! You maybe already guessed where I'm going with this. Each additional counter increases complexity and amount of wires quite significantly. And of course we have a limited amount of physical paths on a die.

In practice, architects don't try to connect every component with every counter, because it increases amount of wires. Instead they try to put counters in a different places on a die to be as closer as possible to the components they are intended to observe. And also they connect each component to at least 2 different counters, so that it's guaranteed to be able to count two different events at the same time. Taking in consideration our example it will look something like this:

![](/img/posts/PMU_counterscounter_distribution.jpg){: .center-image }

Usually there is also one global register that controls all the other counters. For example, with it you can turn all the counters on and off. And that also requires physical paths from the global configuration registers to all the counters in the processor.

### Fixed and programmable counters

In practice most of the CPUs have PMU (Performance Monitoring Unit) with fixed and programmable counters. Fixed PMC (Performance Monitoring Counter) always measures the same thing of the core. With programmable counter it's up to user to choose what he wants to measure.

I believe for the most Intel Core processors, number of fully programmable counters is 8 per logical core and 4 per HW thread (in case of Hyper Threading is turned on), and a number of fixed function counters is 3 (per logical core). Fixed counters usually are set to count core clocks, reference clocks, instructions retired.

My IvyBridge processor ...

```
output from dmesg and cpuid
```

### MSRs - model specific registers

PMU counters and configuration registers are implemented as MSR (Model Specific Registers) registers. What that means is that in theory it can vary from model to model and you can't rely on the same number of counter in your CPU, you should always query that first, using cpuid.

MSRs are accessed via the RDMSR and WRMSR instruction. Certain counter registers can be accessed via the RDPMC instruction. More information and details are available in Volume 2B of the Programmer’s Reference Manual.

### Counting vs. Sampling

Typical use case for such a counter would be:
```
- disable counting
- set all the counters to 0
- configure evenst that we want to measure
- enable counting
- run the application
- disable counting
- read the values of the counters
```
This process is also called characterizing, and this is what such tools do!

This method allows you to collect overall statistics about execution of the application. This is, for example, what `perf stat` will output:

```
 'perf stat -e r5301b1,r53010e,r5301c2,instructions,cycles,branches -- ls'
 #UOPS_EXECUTED.CORE
 #UOPS_ISSUED.ANY
 #UOPS_RETIRED.ALL
```

As you can see, there are no details about the hottest functions or where were the biggest amount of loads, etc. It just raw statistics for the whole runtime. Basically, during the whole runtime each counter measured only one thing. There were no multiplexing between them.

In Intel Vtune Amplifier there is analysis which is called `general-exploration` and it's capable of collecting lots of counters during the runtime, but it's obviously does that by multiplexing between them in the runtime. Multiplexing adds more overhead (because we need to switch counters in the runtime) and decreases the precision.

There is one caveat to this. In particular: what happens when the counter overflows? In this situation you can handle OS exception, and inside this handler you can:
```
- stop counting
- increment the number of overflows in some variable in SW
- clear the counter to zero
- start counting again
```

But before going into more sophisticated things lets consider another fundamental concept called "sampling".

### Sampling and profiling

If you take an OS exception anyway, there is a lot of information you can get from it. For example, you can capture IP (instruction pointer). So if you will dump your IP at the when the counter overflow happend, ta-dam, you know the place in your program where the event occurred.

Say we have our PMU (Performance monitoring unit) counters of 32-bit width. If you start to count clockticks with such a counter and capture overflows, suddenly you will stop your application approximately each 1 second (2^32 cycles, and if the CPU frequency 4.3 GHz) and know what your application executes in this particular moment. And this is more detailed but still quite simplified process of profiling:
```
- set counter to 0
- enable counting
- wait for the overflow and disable counting when it happens
- inside the interrupt handler capture IP, register state, etc.
- repeat the process
```

The problem in this case is that we only sampling every 1 second, which might not be the good precision. To have a finer granularity we can start not at a counters being zeroed out, but at a maximum value minus some threshold. So, if we want to count every 100 ms, we set initial value to `0xFFFFFFFF - 0x19999999`, where `0x19999999` represent the number of clockticks in 100ms. And in this case we will receive an interrupt after 0x19999999 clocks.

Typically very few amount of work is done by the profiling tool during collection of samples. Then there is a separate post-processing stage sometimes called "finalization" which parses all the raw samples, organizes them and convert them into human readable form.

In linux perf profiling associates with `perf record` command. More examples about using perf you can find in the [great article](http://www.brendangregg.com/perf.html) by Brendan Gregg. The similar capabilities for Intel Vtune Amplifier are "hotspot" and "advanced-hotspot" analysis.

Sampling at a smaller intervals increases the overhead (because of more interrupts) and makes the size of collected data bigger. On the other side, counting involves almost no runtime overhead. I will write more about the topic of overhead and how profilers deal with that in my next articles.

That's all for today, in my next post I will dig more into profiling and write about two advanced sampling techniques: PEBS and LBR.


### PEBs

Capture beginning from Brendan's article, then from SDM B.3.3

### LBR

References:
  CERN - overhead of counting and sampling
  http://www.brendangregg.com/perf.html
  SDM v3 - chapters 18,19
  SDM v2 - instructions: RDPMC, RDTSC, RDTSCP, RDMSR, WRMSR
