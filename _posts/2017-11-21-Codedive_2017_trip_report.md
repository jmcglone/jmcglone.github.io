---
layout: post
title: Code::Dive 2017 trip report.
categories: [personal]
---

This is my third time [Code::dive](http://codedive.pl/) conference and I was really happy to be back to Wroclaw. To be back to this wonderful city, to my Nokia ex-colleagues and friends.

This year it was again 2-day conference with 4 tracks and two 90-minute and three 60-minute session per day. As before this conference is completely free and open for everyone (you just need to register on time), so I'm really thankful to Nokia for such a great event!

This time the focus was made not only on C++ but also on other languages like Rust and Go. There were also some amount of talks about security, embedded, IoT and DevOps.

Speaking of speakers: we had John Lakos, Eric Niebler, Mark Isaacson (Facebook), Alex Crichton (Mozilla) and others. All videos will be on youtube and [codedive.pl](http://codedive.pl/) within couple of weeks I hope.

The talks that I enjoyed the most are:
- Andrzej Krzemieński (@akrzem9) - Faces of undefined behavior.
- Mateusz Pusz (@mateusz_pusz) - Striving for ultimate low latency.
- Alex Crichton - Intro to Rust.

There was a cool performance by Mark Isaacson and the whole audience on his "Developing C++ @ Facebook scale" talk. There was a rain simulation by the people in the room and by Mark. You should definetly go see it when the video will be published.

Nice surprise was the escape room, prepared by the Sławomir Zborowski and others. I didn't manage to try it, but what I heard from others - it was quite hard, but lots of fun.

Best quote from the conference for me was by Mark Isaacson from his "Exploring C++17 and Beyond" talk. He said: "We should not like metaprogramming". And the context was that people tend to use dirty metaprogramming tricks because they didn't have better choice. Now with c++14 and c++17 it's getting more and more easier to do compile-time computations without going into hacks.

And I want to point out one thing that I didn't like. There were a slots with only one c++ talk. And even if it was not a world-famous speaker, still there was a "full house" on this talk. Just because there was no other alternatives. I was lucky to enter the room for all the talks I wanted, but I know people that weren't.

Now I want to share my insights from the conference

### How UB is connected with opt level

The talk by Andrzej about UB was great. First of all, he showed why we should not do defensive checking against UB, thus widening the contract of our function:
```cpp
int foo(int x)
{
  return x + 1; // potential integer overflow
}
```
We shouldn't insert check in our function because it will block static analyzers (clang in particular) from detecting real bugs on caller side. What we should do is fix a bug on a caller side instead.

Andrzej showed us really simple example of UB:
```cpp
int foo()
{
    int* p = nullptr;
    return *p;
}
```
With `-O0` clang just inserted the dereferencing of null pointer in our machine code, but starting from `-O1` this function has just one instruction: `ret`. So, clang assumed that UB can't happen and just optimized it away.

What got me interested during this talk was "How UB detection is connected with optimization level?"

After I came back from the conference I experimented with different examples a little bit (also asked llvm-dev community) and found out that front-end (clang) is rather light-weight in detecting UB, and all the cool stuff is done inside middle- and back-end (llvm). Optimization of UBs is spread across different passes, so there is no single pass, dedicated for exactly this purpose. You can check the sequence of passes for different opt levels [here](https://stackoverflow.com/questions/7796151/where-to-find-the-optimization-sequence-for-clang-ox?noredirect=1&lq=1).

The full thread on llvm-dev mailing list can be found [here](https://groups.google.com/forum/#!topic/llvm-dev/4GWRsfYbiAQ).

### Loop interchange in modern compilers

Another great talk was done by Mateusz Pusz about what you should do when you want to optimize for low latency, not the throughput.
And he showed one simple example of a not-cache-friendly loop:
```cpp
void foo(int** a, int** b)
{
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            a[j][i] += b[j][i];
}
```

I was wondering if compilers can interchange the loop to make it cache-friendly again. So I did some experiments at home and asked clang/gcc compiler devs about that. The results I received is that they are capable of doing that in general, but clang and gcc are missing proper data analysis to make this transformation.

Specifically for clang there is special opt pass which is not enabled by default, you should pass `-mllvm -enable-loopinterchange` explicitly. GCC is also making this transformation if it can prove that `a` and `b` do not alias, and even vectorize this loop which is quite optimal.

Full tread on llvm-dev mailing list can be found [here](https://groups.google.com/forum/#!topic/llvm-dev/RRc7m1cuVxw).

That's all for year 2017. Hope to be on CodeDive again in 2018!
