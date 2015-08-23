---
layout: post
title: "Hackable from Anywhere Blogging Infrastructure"
date: "2015-08-23"
tags:
  - writing
---

Over the past couple of years I've made a concerted effort to write a blog post at least once a month.  My motivation for this goal has been to improve my writing overall and use my blog as a playground to document my latest experiments or crazy bug fixes.

Forcing myself into this habit has been great for learning.  In order to write up a post of something that I've learned it really takes digging into just a bit deeper to organize my thoughts and I've found that helps make the lessons stick.  I've also found myself referencing my own posts to recall something I've learned months later.

### Getting Started

Before I started writing on my own blog I'd done some occasional writing elsewhere and found that not having a simple way to quick post an idea resulted not posting at all.

To get to point where publishing was easy I wanted to have a process for writing posts that was minimal enough to help me focus on writing.  Also wanted to be able to write in [Github flavored Markdown](https://help.github.com/articles/github-flavored-markdown/) like I do throughout the day when I'm working on projects.

Ruby being my go to language these days and wanting to give [Github pages](https://help.github.com/articles/using-jekyll-with-pages/) a try for hosting, I settled on using Jekyll for my blog.

### Plugins

One limiting factor of Github pages and it's auto building feature for Jekyll sites is that you can't use an plugins.

To get around this problem I created a [rake task](https://github.com/calebwoods/calebwoods.github.io/blob/source/Rakefile) that would build my site locally in a git repo and force push to Github pages. 

This means once I finish a post all I need to do is run `rake publish` and it will deploy the static files to Github.

### Writing from Anywhere

This setup works pretty well, but it did create a bit of a problem where the only way I could publish a new blog post is on my main development machine where I had a full Ruby setup.  Definitely not very minimal.  Instead I wanted to be able to complete my full writing workflow from my [Chromebook](https://www.google.com/chromebook/) to avoid the distractions of my main work computer.

After looking at ways of setting of Git and Ruby on the Chromebook I finally settled on the requirement to be able to use a web browser.  Because my site is a repo on Github the file creation and web editing is solved aspect is solved.  Github's markdown editor in full screen is actually a  very nice distraction free way to write a blog post.

This meant I just needed a way to deploy from a browser to complete my setup.

### Deployment Pipeline

I've used a number of Continue Integration services, but for my last few personal projects I've been using [Wercker](http://wercker.com/).

My setup is pretty simple and all the build steps are defined a [wercker.yml](https://github.com/calebwoods/calebwoods.github.io/blob/source/wercker.yml) file.  On each push to my Github repo a wercker build is kicked off which installs the needed gems and builds the Jekyll site.

If that succeeds then I can kick off the deployment which again builds the environment and runs the same rake tasks that I could run in local Ruby environment.  Wercker also make it easy to set ENV variables and SSH keys which I use to be able to connect to [Algolia](https://www.algolia.com/) and store an SSH key for Github.

Overall I've been pleased with this setup and have become a big fan of using static sites, especially when paired with a Javascript frontend.  It's just enough flexibility to allow me to experiment and make the site my own and while adding the write kind of constraints to push me back to actually writing blog posts.
