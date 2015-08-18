---
layout: post
title: "Hackable from Anywhere Blogging Infrastructure"
date: "2015-08-17"
tags:
  - writing
---

Over the past couple of years I've made a concerted effort to write a blog post once a month.  My motivation for this goal has been to improve my writing overall and use my blog as playground to document my latest experiments or crazy bug fixes.

Forcing myself into this habit has been great for learning.  In order to write a post of something that I've learned it really takes digging in just a bit deeper to organize the material and I've found that makes the lessons stick.  I've also found myself referencing my own posts to recall something I've learned.

To get to point where posting was easy I wanted to have a process for writing posts that was minimal enough to help me focus on writing and not the tools.  Also wanted to be able to write in Github flavored Markdown like I do through the day when I'm working on projects.

Being a primarily Ruby developer I settled on Jekyll as my main tool and decided to give Github pages a try for free hosting.

### Plugins

After getting a few posts published, I started looking at how I could better cross reference my posts and make the site more usable.

I've add support for related posts using Jekyll's LSI, search with Algolia (more on this in a future post), and a sitemap.  Great features, but they required me to use some Jekyll plugins which meant I couldn't just push to Github and have the site built automatically.

So I borrowed a rake task structure from [link] and customized to suit my needs.  This means once I finish a post all I need to do is run `rake publish` and it will force push the static files to the needed repo.

### Writing from Anywhere

This did create a bit of problem where the only way I could write is on my main development machine where I had a full Ruby setup.  Not very minimal.  My goal was to be able to complete my full writing workflow from my Chromebook.

After looking at ways of setting of Git and Ruby on the Chromebook I finally settle on that fact that I'd like to be able to use just a browser.  Because my site is a git repo on Github the file creation and web editing is solved.  Github's markdown editor full screen is actually a nice distraction free way to edit a blog post.

This meant I just need a way to deploy from a browser to complete my setup.

### Deployment Pipeline

I've used a number of Continue Integration services, but for my last few personal projects I've been using Wercker.

My setup is pretty simple and all defined in my site's wercker.yml file.  One each push to my Github repo a wercker build is kicked off which installs the needed gems and builds the Jekyll site.

If that succeeds then I can kick off the deployment which again builds the environment and runs the same rake tasks that I could run in local Ruby environment.  Wercker also make it easy to set ENV variables and SSH keys which I use to be able to connect to Algolia and Github respectively.

Overall I've been with the setup and have become a big fan of the idea of static sites, especially when paired with a Javascript frontend.  It's just enough flexibility to allow me to experiment and make the site my own and just enough of a constraint to push me back to actually writing posts rather than hacking on features.
