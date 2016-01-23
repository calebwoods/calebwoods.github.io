---
layout: post
title: "Naming Projects"
date: "2016-01-23"
tags:
  - workflow
  - projects
---

Over my career I've had the chance to lead dozens of software projects from small internal tools to systems that organizations run their businesses on.  During that time I've come to appreciate the power of good names for projects and the affect that can have on the productivity and perceived success of a software project.

### Benefits

Talking about naming and its benefits to computer programming is not a new concept. Metaphors are a widely adopted part of object oriented programming as it allows reasoning about your object through understood mental models.

So if we know naming is important inside our projects, are there benefits of meaningful project names as well?

#### Reset Expecations

If a project is replacing an existing system and you keep the same name but add a modifier like "v2" you criple your chance to make changes.  Stakeholders expect it to work like old system (even if it was painful) plus add the new functionality they want.  However, if you start with a new name they will evaluate the way the problem was solved from a clean slate.

#### Reduce Confusion, Add Meaning

![Old Book](https://pixabay.com/static/uploads/photo/2015/06/14/19/24/book-809396_960_720.jpg)

With a lot of business software the names are picked describe the type of system rather than a unique way to identify the system.  Over the past couple of years I've worked on an internal reporting tool for our consultancy that reads data from our time tracking service called Almanac. The tool analyzes each employee's billable hours, a leading indicator of profitablity for our company, to ensure they are on track. It could have been called Billable Hours Tracker, but instead I chose the name Almanac as a metaphor for analyzing past data to help us forecast the future just a farmer would use an almanac.

#### Spark Creativity

As a Software Craftsman, working on projects is about finding creative ways to solve problems.  That's not an easy task, so drawing inspiration and excitment from even the small things like the name of a project has power.  From my experience, giving teams the chance to name their project creatively also gives them greater ownership over the success of the project. If the name of a project is a metaphor it may even help you to think about the problems you are solving in a different context.

### Naming Strategies

> There are only two hard things in Computer Science: cache invalidation and naming things. -- Phil Karlton

Let's assume that you buy into the idea that having meaningful names for your projects is a good idea. How do you come up with these names?  Here are some strategies I've used over the years.

#### Thesaurus

Is there a meaningful word or phrase that you can use to describe your project?  Maybe you can think of one, but it seems too common.  Using a [Thesaurus](http://www.thesaurus.com/) can be a great way to find rarely used synonyms that could fit your project. 

#### Translations

Names don't alway have to make sense in your native language, but they should be memorable.  As an example I once built a simple tool which had the purpose of sending from one service to another one, basicaly tying the systems together.  For this project I chose the name cravatta which is the Italian word to tie a tie.  While the transaltion wasn't perfect, being able to think about project as a single word crystalized the purpose of the project.

### Themes

<a data-flickr-embed="true"  href="https://www.flickr.com/photos/viewfrom52/2081809198/in/photolist-4aXPm3-xQ9S6-dJQ7Vv-yamepw-5ttdFu-7Xq1Ub-pdMSEc-4ExKyW-oDwAMA-cFjJZ7-bHb4wP-r3e4q2-rBAav-izKAw9-dJSRbw-4wdgAy-4LFF3N-iM16xm-e1opzS-fC2o6P-usDK6z-6YJdRB-bNNyRa-4HokX9-s1tazj-4YC5ci-DWZhr-c2foK5-c2h171-fChuPh-crVy8w-crVwNw-6o7uGo-DuoK-dJMpaD-sfisWV-bXeBmS-BDrHMN-zSreN-4D92hb-993MhT-8BGWku-nfnskb-qwFx8-nJuFHc-bqy3sY-8H5Fia-bDsWmR-fFBJzL-hwA6H" title="Best Elephant Photo!"><img src="https://farm3.staticflickr.com/2210/2081809198_69da6be083_n.jpg" width="320" height="213" alt="Best Elephant Photo!"></a><script async src="//embedr.flickr.com/assets/client-code.js" charset="utf-8"></script>

With the rise of Service Orient Architechure (SOA) there comes an opportunity for names to follow a theme and fit into an interesting narative.  On my most recent project, as an example, we began to split out the pieces for the data warehouse application that we were building and needed to come up with a naming scheme for these services.  We ended up with 3 pieces: data extraction, data processing/storage, and customized reporting.  Being that several big data tools already have animal mascots we decided on: Hippo (think hugry hippos), Elephant (never forgets), and Rhino (sounds cool) for our project names.  These unique names have given us a framework for discussing data interaction that we wouldn't have had with more generic names.

### Conclusion

In my opinion naming is a skill and form of creativity that can be a huge benefit to software teams and should be exercised often.  At times these creative names may only end up being internal code names, but I've never regretted dropping a generic name for something unique. What techniques have you used when naming a project?  Tweet at me [@calebwoods](https://twitter.com/calebwoods), I've love to hear your experiences.
