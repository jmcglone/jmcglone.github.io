---
layout: post
title: Reference exporting guide from Mendeley to Ms Excel !
date: 2020-01-06
---

If I may quote *Therese Fowler* "Some rules are nothing but old habits but old habits that people are afraid to change". 
I recently had to break one of my habits which is using LateX for my writing activities. For the need of a paper I have been working on, 
I used Ms-Word for the entire paper and I came accross an issue. In fact, as the article was a systematic mapping, and for the need of data analysis,
I needed to export my references into a csv file to be used in Ms Excel.

It was new because I have been used to deal with BibTex databases only. From my online investigations, I did not find any tool that could do the 
trick in a one step conversion ;). Let me take you through the steps I have identified to be most rigourous and robust way to d the conversion. 
I assume that we all use a reference manager ;) I personnally use Mendeley therefore the steps might be different if you use another one.

* Step 1: Export from Mendeley to BibTex 

In Mendeley Desktop 
 * File --- >  Export
 * Save as type --- > BibTex (*.bib) 
 
 * Step 2: Using JabRef
 
 Once you have your BibTex file, you have to open it in JabRef
 ** File --- >  Open database
 ** And select the BibTex file
 
 * Step 3: JabRef to CSV
 
  ** File --- >  Export
  ** Choose CSV file type (*.csv)
 
 * Step 4: Import your csv file to Excel
 ** Open a new Excel document
 ** Go to data tab and click "From Text"
 ** Navigate to the csv file from the opened window and click import
 ** Choose "Delimited" from the new window and click "next"
 ** Check the box next to "type of Delimietr" (comma)
 ** Click finnish 
 
As you can see from above, it is a bit tedous but I can ensure you that it works perfectly free of errors and it is always better than typing in
our data line by line into Ms-Excel. At this point, according to your data extraction methodology, you can easily add/use information at your will.

If you come accross a tool that could do this in one step, it goes without saying that I want you to let me know! 
If you think this could interst a peer of yours, feel free to share...
