---
layout: post
title: Vectorization part5. Multiversioning by data dependency.
categories: [vectorization]
---

Vectorization doesn't always come for free. In this post we will see what penalties we have to pay with vectorization.

Without further ado let me show you example of the code:
```cpp
void foo( unsigned short * a, unsigned short * b )
{
  for( int i = 0; i < 128; i++ )
  {
    a[i] += b[i]; 
  }
}
```

Now lets consider a kind of weird invocation of this function:

```cpp
  unsigned short x[] = {1, 1, 1, 1, ... , 1}; // 129 elements
  unsigned short* a = x + 1;
  unsgined short* b = x;
  foo (a, b);
```

In scalar version we will receive results: `x = {1, 2, 3, 4, 5, ... }`.
But in vector version we will first load some portion of a (starting from x + 1). Then we will load some portion of b (starting from x). Then we will add two vector registers together, resulting in `x = (2, 2, 2, 2, ...)`. Oops! Something is wrong.

Vectorized version of the loop works perfectly fine as long as input arrays do not alias (there is memory intersection).

To protect from this problem compilers insert **runtime** checks for arrays aliasing. Lets see what clang 5.0 generated for us ([link to godbolt](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(j:1,source:'void+foo(+unsigned+short+*+a,+unsigned+short+*+b+)%0A%7B%0A++++for(+int+i+%3D+0%3B+i+%3C+128%3B+i%2B%2B+)%0A%09%7B%0A++++++++a%5Bi%5D+%2B%3D+b%5Bi%5D%3B+%0A%09%7D%0A%7D'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),header:(),k:50,l:'4',m:100,n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang500,filters:(b:'0',binary:'1',commentOnly:'0',demangle:'0',directives:'0',execute:'1',intel:'0',trim:'0'),libs:!(),options:'-O3+-march%3Dcore-avx2',source:1),l:'5',n:'0',o:'x86-64+clang+5.0.0+(Editor+%231,+Compiler+%231)',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4)):

```asm
  lea rax, [rsi + 256] # calculating the end of b (b + 128)
  cmp rax, rdi         # comparing the beginning of a and the end of b
  jbe .LBB0_4
  lea rax, [rdi + 256] # calculating the end of a (a + 128)
  cmp rax, rsi         # comparing the beginning of b and the end of a
  jbe .LBB0_4
  xor eax, eax
  <scalar version>
.LBB0_4:
  <vector version>
```

As you can see there is some runtime dispatching between scalar and vector version of the same loop. This is what is called *Multiversioning*.

![](/img/posts/MultiversioningByDD/RuntimeAliasing.png){: .center-image }

Normally pointer aliasing is rather rare case, but we don't know for sure, so we need to have a runtime check for that. If you are sure that your arrays will never alias you can use `__restrict__` keyword to tell the compiler about it: ([link to godbolt](https://godbolt.org/#g:!((g:!((g:!((h:codeEditor,i:(j:1,source:'void+foo(+unsigned+short+*+__restrict__++a,+unsigned+short+*+__restrict__+b+)%0A%7B%0A++++for(+int+i+%3D+0%3B+i+%3C+128%3B+i%2B%2B+)%0A%09%7B%0A++++++++a%5Bi%5D+%2B%3D+b%5Bi%5D%3B+%0A%09%7D%0A%7D'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),header:(),k:50,l:'4',m:100,n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang500,filters:(b:'0',binary:'1',commentOnly:'0',demangle:'0',directives:'0',execute:'1',intel:'0',trim:'0'),libs:!(),options:'-O3+-march%3Dcore-avx2',source:1),l:'5',n:'0',o:'x86-64+clang+5.0.0+(Editor+%231,+Compiler+%231)',t:'0')),k:50,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',n:'0',o:'',t:'0')),version:4)). As you can see runtime check was removed.

Situation gets somewhat complex when there are multiple arrays in the function arguments. This significantly increases the number of runtime checks in the beginning of the function. Gcc even has heuristic for that: `--param vect-max-version-for-alias-checks` which is 10 by default.

Another frequently used runtime check for the compiler is testing number of loop iterations. It should not be negative or lower than the [vectorization width]({{ site.url }}/blog/2017/11/02/Vectorization_width).

### All posts from this series:
1. [Vectorization intro]({{ site.url }}/blog/2017/10/24/Vectorization_part1).
2. [Vectorization warmup]({{ site.url }}/blog/2017/10/27/Vectorization_warmup).
3. [Checking compiler vectorization report]({{ site.url }}/blog/2017/10/30/Compiler-optimization-report).
4. [Vectorization width]({{ site.url }}/blog/2017/11/02/Vectorization_width).
5. Multiversioning by data dependency (this article).
6. [Multiversioning by trip counts]({{ site.url }}/blog/2017/11/09/Multiversioning_by_trip_counts).
7. [Tips for writing vectorizable code]({{ site.url }}/blog/2017/11/10/Tips_for_writing_vectorizable_code).
