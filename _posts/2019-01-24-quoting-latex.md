---
layout: post
title: Quoting in LaTeX
date: 2019-01-24
description: How to use the basic quoting environments in Latex, "quote" and "quotation"
tags: latex quote quotation tex
---

## Quotation: What and why?

For each writer or, in any case, serious author (i. e. bloggers, academicians, authors, etc.) it's elementary to possess a decent quoting tool. A quoting tool permits to spotlight text in dedicated environments separated from standard context.
It may be a fraction from a book, an article, a speech, a poetry or each alternative source to pur in evidence.

Quoting effectively is vital as a result of the correct quotation given properly will add spice, interest, thought, effectivenes, support, and relevance your writing. Further reading [here](https://books.openedition.org/obp/927?lang=en), an exellent piece by [Prof Ruth Finnegan](http://www.open.ac.uk/people/rhf2) I recommend.

## Quoting environments in Latex 
As you may imagine, in LaTeX there is not only one quoting environment. There are several environments for different purposes and different outputs. However, in this post we will focus on the fundamental classes for quoting.

<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<ins class="adsbygoogle"
     style="display:block; text-align:center;"
     data-ad-layout="in-article"
     data-ad-format="fluid"
     data-ad-client="ca-pub-4729293279921640"
     data-ad-slot="6265917844"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
| Env           | When?       | 
| ------------- |:-------------:| 
| Quote         | quote for a short quotation, or a series of small quotes,|    
|               | separated by blank lines. |             
| Quotation     | quotation for use with longer quotations, of more than one| 
|               |   paragraph, because it indents the first line of each paragraph. |


### Quote, e.g.



```Latex
 \documentclass{article}
 \usepackage{lipsum}

 \begin{document}

  [...] Before quote 
     \begin{quote}
         \lipsum[1]
     \end{quote}
  After quote [...]
  
  \end{document}
```
### Output

![alt text](https://github.com/mkantem/mkantem.github.io/raw/master/img/quote.PNG "Output using Env Quote")

### Quotation, e.g.

```Latex
\documentclass{article}
 \usepackage{lipsum}

\begin{document}

[...] Before quotation
    \begin{quotation}
        \lipsum[1-2]
    \end{quotation}
After quotation [...]
\end{document}

```
### Output

![alt text](https://github.com/mkantem/mkantem.github.io/raw/master/img/quotation.PNG "Output using Env Quotation")


For further environments, you can chexk out packages like dirtytalk, csquotes or epigraph.
They are all available on the Comprehensive TeX Archives Network [CTAN](https://ctan.org/).


Thanks for stopping by, I might write about some of the packages cited above in the future. 
Feel free to use the comment box!


