---
layout: post
title: Code::Dive 2016 trip report.
categories: [personal]
---

It's my second time I've beed on Code::Dive conference in Wroclaw.
This year it was on 15-16 November. We had a really great speakers such as Chandler Carruth, Sean Parent and Mark Issacson.

It was amazing opportunity to hear talks on compiler optimizations, clang tools, undefined behaviour, C++ history and future and best practices.
All talks should be available on youtube shortly.

Really many-many thanks to Nokia for such a great free conference!
Looking forward to attend next year (probably as a speaker).

Things I learned from this conference:

1. If you do not turn off exceptions, compiler will generate emergency buffer. This memory space is needed for example, when you're throwing `out_of_memory` exception. Some amount of memory should be allocated somewhere, but you are already out of memory, so you need some preallocated storage for it. More on this topic here: [Emergency buffer for exceptions](https://developer.arm.com/docs/dui0475/m/the-arm-c-and-c-libraries/tailoring-the-c-library-to-a-new-execution-environment/emergency-buffer-memory-for-exceptions).

2. Passing `-fno-exceptions` to the compiler will instruct it to turn every `throw` calls in STL into `std::abort`. Also compilers are able to detect lack of `catch`'es in your program. In this case they will convert each `throw` call in your programm to `terminate`, because noone will catch it either way. More details on [stackoverflow question](http://stackoverflow.com/questions/7249378/disabling-c-exceptions-how-can-i-make-any-std-throw-immediately-terminate).

3. Finally I got to know that dereferencing of nullptr is undefined behaviour. Because on some platforms (with direct memory mapping) dereferencing null pointer means accessing memory with offset 0x0. More information on [stackoverflow question](http://stackoverflow.com/questions/2727834/c-standard-dereferencing-null-pointer-to-get-a-reference).

4. "No raw synchronization primitives" by Sean Parent. Coming soon on youtube and [Code::Dive](http://codedive.pl/en/index/).

5. "Try to avoid `inline` keyword" by Chandler Carruth. Coming soon on youtube and [Code::Dive](http://codedive.pl/en/index/).
 
