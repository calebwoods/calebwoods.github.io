---
layout: post
title: "'Simple' Git Merge Strategy"
date: 2014-03-22 17:58:54
---

At work we adopted use of the [simple branching strategy](http://blogs.atlassian.com/2014/01/simple-git-workflow-simple/) for our use of git. The goal of this approach over something like Git Flow is to reduce the complexity of branching and create a workflow that is easy to follow.

### What is 'simple'

At it's core it means following these 2 rules.

1. `master` should alway be deployable
2. feature branches are `rebased` on `master` before merging

In addition to the basic semantics we've evolved the workflow to include 2 more rules.

### Story Card == Feature Branch

To help keep branches small we scope each feature branch to just 1 story card from our board. This also means that we create a lot of branches so help manage the naming we include the card number in the branch name, such as `task_1234324_add_email_notification`.

This makes it simple to find branches and ensure they stay in sync with corresponding card.

### Meaningful Merge Messages

If you are using Github and Pull Requests then you already have the benefit slightly better merge commit messages which include the Pull Request number. In most of our projects, however, it's also useful to include the story card number in the commit for tracking purposes. This also gives us more values to search

To do that we developed a standard merge commit message format.

```
<feature summary> [<card system abbrev> #<number>] (<source abbrev> #<number>)

<feature long description, optional>
```

Filled out it looks something like this.

```
Refactor API to proper 404 responses [KB #1142645] (GH #67)

Updated the API so when a user does not have access to a resource they will get a 404 status code rather than 403.
```

To make filling out this message even easier I'd suggest taking a look at the [git_pretty_accept](https://github.com/lovewithfood/git_pretty_accept) gem. It allows you to create a merge commit message template and automatically removes local and remote branches after the merge.

### Conclusion

Optimizing processes for ease of use maximum effectiveness is always a moving target, but this strategy has been working well on the projects I've used it.

For practical explanation of 'simple' branching with examples checkout this [gist](https://gist.github.com/jbenet/ee6c9ac48068889b0912).
