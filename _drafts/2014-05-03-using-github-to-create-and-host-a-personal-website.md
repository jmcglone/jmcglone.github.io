---
layout: post
title: Using GitHub to Create and Host a Personal Website
---
This is an overdue note about my switch to using GitHub and Jekyll for this website.

After 10+ years using WordPress I finally made the switch to GitHub Pages (confession: I still use WordPress for certain projects at work). My switch largely centered around this rant that played itself out quite frequently in my head: 

When you want something simple, having a WordPress site often comes with a lot of other things: a web hosting plan, updating plugins, monitoring auto-updates so your site's template and functionality don't break, a MySQL database, dealing with being a target for hackers, a lot of clicking around and fussing with settings, hacking Thesis, and on and on. <!-- flesh the previous sentence out with links --> For a personal website that features just few pages, a CV, and maybe a place to write blog posts and link to your social media accounts and departmental web pages – or just experiment around with the awesomeness of HTML5 <!-- flesh this out with links to codepen stuff or --> and the amazing things you can do with client side scripting <!-- ahem, more links -->, WordPress is bloated. 

Do I really need to make a database call to serve an About page with less than 500 words on it? No. Do I want a bunch of third-party scripts from whatever plugin author(s) just to have social sharing tools? No. Do I want to have to hack PHP in an existing WordPress template to adjust the banner for my logo or to just simplify the user experience? No. I still want to be able to get up and running in less than five minutes, but can't it be a little lighter?

So I made a wishlist of the things I wanted for a personal website:

* simplicity
* good performance and reliability
* no databases
* hosting to be free or really cheap
* a custom domain
* the ability to work on my site from anywhere if needed
* to use open source tools supported by an active development community
* to get up and running quickly
* to have version control on my website, preferably Git
* to be able to share my code so others can easily re-use it

<a href="http://staticgen.com/">There are a lot of lightweight CMS options out there</a>, but I fell for the GitHub + Jekyll toolchain. It's well known and now pretty established, and the partnership it has developed with Jekyll developers (it's based in Ruby) and its use of Markdown to separate content from markup just seemed to click with me as a digital publisher. It may not be for everybody, but after an afternoon playing around with and getting over the learning curve, I think it can be for a lot more than developers.

That's why after building my site from scratch (along with the help of Bootstrap), I've finally taken it a step further and created a <a href="/guides/github-pages/" title="Creating and Hosting a Personal Site on GitHub">beginner's guide to getting started building and hosting a personal website and blog with GitHub Pages and Jekyll</a>. It is very step-by-step. The goal is to make GitHub and Jekyll more accessible to a wider audience interested in an alternative to WordPress. It even refactors code to teach you how Jekyll templates work. And I should note, it was created to accompany a workshop I gave during <a href="http://ttc.iss.lsa.umich.edu/ttc/enriching-scholarship/">University of Michigan's 2014 Enriching Scholarship Conference</a>.
