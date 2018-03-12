---
layout: post
title: Embo 2018 trip report.
tags: default
---

### It was a great pleasure to be with embo 2018.

I really enjoyed being on [embo++ conference](https://www.embo.io/) this year. It was 2nd edition which was held in Bochum(Germany) from 8-12 March 2018. Everything was well organized starting from picking every attendee from the underground station to the quality and amount of food and drinks provided to us.

![](/img/posts/Embo2018TripReport/logo.jpg){: .center-image }

Also I really want to say big "Thank you!" to all the sponsors for nice gifts, great venue and tasty food.

Breaks between the talks were long enough, so there was enough time for networking and just hanging with the nerds. I met cool people that are doing interesting projects: tiny devices with bare metal programming, automotive industry robots with tough real-time constraints, huge telescopes with a lot of precision and math inside them, and so on. Really had a great time just talking to the people. I think that every attendee was interesting enough to spend couple of hours discussing his/her project and ideas.

### Talks and workshops

The conference was made of 2 main days, pre- and post-event.

![](/img/posts/Embo2018TripReport/Ben.jpg){: .center-image-width-50 }

There were lightning talks at the pre-event, where I presented how compilers can generate multiple assembly code versions for the single piece of code. This talk was basically the essentials of the series of [my posts about vectorization](https://dendibakh.github.io/blog/2017/11/03/Multiversioning_by_DD).

On this pre-event I want to specifically mention guys (Phillip and Benjamin) from Bochum university who reverse engineered AMD microcode. Here is their [paper](https://www.syssec.rub.de/media/emma/veroeffentlichungen/2017/08/16/usenix17-microcode.pdf) presented on Usenix 2017 on August 2017. Also the [video](https://www.youtube.com/watch?v=I6dQfnb3y0I) is available on youtube.

Then there was a workshop day. I was on the Rainer Grimm's (@rainer_grimm) lecture about templates and Kris Jusiak's (@krisjusiak) workshop about state machines. Even though it does not affects my work right now, it always good to refresh knowledge about C++ templates and learn something interesting about state machines.

On the second day there only talks (including mine), so it was more dynamic in a way.

I especially liked the talks by:
- Ben Craig with proposal about standardizing OS-less version of STL.
- Odin Holmes (@odinthenerd) summarizing everything that was presented in the conference.
- Niklas Hauser (@salkinium) about some new security features of ARM processors.

The talks were scheduled really nicely in my opinion. On both days speakers presented their take on the problems in embedded domain and then Odin summarized everything in his closing keynote. So, you kind of understand how that all fits together.

The last day was a study group meeting, where we tried to come up with the future plans. Here is one photo from this:

![](/img/posts/Embo2018TripReport/PostEvent.jpg){: .center-image-width-50 }

### My talk

My talk was about performance analysis and was well received(I guess) although it was not strictly related to embedded programming.
It was my first experience speaking at the major conferences, so I was nervous a little bit at the beginning, but suddenly this "nervous switch" was turned off, and everything went fine from there.

![](/img/posts/Embo2018TripReport/Denis.jpg){: .center-image-width-50 }

Hope to see the recordings and reflect on that soon. :)
Slides for my talk are available on my [github](https://github.com/dendibakh/dendibakh.github.io/blob/master/_posts/presentations/Dealing-with-performance-analysis.pdf).

Simon Brand (@TartanLlama) noted that we should stop writing "C/C++" which is exactly what I did :) . My talk has title "Dealing with performance analysis in C/C++". Those two languages are not the same and it's wrong to mix them. In the end, I didn't meant to mix them, rather just wanted to attract both C and C++ developers. Actually, my talk was focused even more on assembly than C++. Anyway thanks, Simon, I will try to avoid mixing C and C++ it in the future.

### Embedded world needs help !!!

Especially people who target bare metal. In most cases they are not allowed to dynamically allocate memory, because heap is not supported on their system. So they just simply can't use most part of STL, because std::vector, std::string, std::function and so on might allocate. Another "no-no" for the STL is C++ exceptions. On most of such systems they are not supported.

So, Ben Craig tries to come up with the proposal to C++ comitee for standardizing OS-less (free-standing) version of STL where such things will be removed. It will help to write portable code for bare metal projects.

I wish him good luck as he goes through the standardization process.

If you are in embedded domain and want to solve your problems more efficiently and willing to help, reach out to the guys at [embo](https://twitter.com/emBOconference) (@emBOconference). They will be really glad for having more hands on this stuff.
