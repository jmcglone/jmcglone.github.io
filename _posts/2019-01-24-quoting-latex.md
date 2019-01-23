---
layout: post
title: Quote and Quotation in LaTeX
date: 2019-01-24
---

## Quotation: What and why do?

For each writer or, in any case, serious author (i. e. bloggers, academicians, authors, etc.) it's elementary to possess a decent quoting tool. A quoting tool permits to spotlight text in dedicated environments separated from standard context.
It may be a fraction from a book, an article, a speech, a poetry or each alternative source to pur in evidence.

Quoting effectively is vital as a result of the correct quotation given properly will add spice, interest, thought, effectivenes, support, and relevance your writing. Further reading [here](https://books.openedition.org/obp/927?lang=en), an exellent piece by [Prof Ruth Finnegan](http://www.open.ac.uk/people/rhf2) I recommend.

## Quoting environments in Latex 
As you may imagine, in LaTeX there is not only one quoting environment. There are several environments for different purposes and different outputs. However, in this post we will focus the fundamental classes for quoting.

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
