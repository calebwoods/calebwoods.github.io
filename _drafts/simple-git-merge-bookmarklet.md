---
layout: post
title:  "'Simple' Git Merge Strategy"
date:   2014-03-22 10:58:54
---

At work we adopted use of the [simple branching strategy](http://blogs.atlassian.com/2014/01/simple-git-workflow-simple/) for our use of git.  The goal of this approach over something like Git Flow is to reduce the complexity of branching and create a workflow that is easy to follow.

### What is "simple"

* `master` should alway be deployable
* feature branches are `rebased` on `master` before merging

In addition to the basic semantics we've evolved the workflow to include 2 more rules.

### Story Card == Feature Branch

To help keep branches small we scope each feature branch to just 1 story card from our board.  This also means that we create a lot of branches so help manage the naming we include the card number in the branch name, such as `task_1234324_add_email_notification`.

This makes it simple to find branches and ensure they stay in sync with corresponding card.

### Meaningful Merge Messages

If you are using Github and Pull Requests then you already have the benefit slightly better merge commit messages which include the Pull Request number.  In most of our projects, however, it's also useful to include the story card number in the commit for tracking.

To do that we developed a standard merge commit message format.

```bash
<summary of feature> [<card system abbrev> #<number>] (<Source Control abbrev> #<number>)
```

Filled out it looks something like this.

```bash
Return 404 on posts API when no access [KB #1142645] (GH #67)
```

To make filling out this message even easier I've created a [bookmarklet](https://gist.github.com/calebwoods/8466688) which auto populates your Github merge commit message with as much information as possible.  All that's needed is to fill in card number.

### Conclusion

Optimizing processes for ease of use maximum effectiveness is always a moving target, but this strategy has been working well on the projects I've used it.

For concise and practical explanation with examples checkout this [gist](https://gist.github.com/jbenet/ee6c9ac48068889b0912)

http://www.rubyflow.com/items/10445-git-pretty-accept-accept-pull-requests-the-pretty-way

