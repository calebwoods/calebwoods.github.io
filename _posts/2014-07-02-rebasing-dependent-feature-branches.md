---
layout: post
title:  "Rebasing Dependent Feature Branches"
date:   2014-07-02 17:15:00
---

In a recent post I wrote about the ['Simple' Git Merge Strategy](http://www.calebwoods.com/2014/03/22/simple-git-merge-strategy/) that I've been using on my recent projects.

This post will look at how to resolve the issue of rebasing on `master` when your feature branch was started from another feature branch which has since been rebased and merged.

### Background

For this post we will assume the following branches: `master`, `feature1`, and `feature2`. We will assume that `feature1` is a work in progress, however, it contains changes we need to build off of for `feature2`.

We will also be using the strategy of rebasing on `master` and squashing commits before merging.

### Setting the stage

Our git repo contains just one file, `file.txt`, which on `master` looks like:

```
content
```

In our `feature1` branch we have made two commits, B and C, which result in the following state:

```
content
edit1
edit2
```

We also have another branch, `feature2`, which is based on `feature1` and has one commit, D, to add another edit. The final `file.txt` looks like:

```
content
edit1
edit2
edit3
```

This results in the following git history:

```
 A
 o  master
  \
   B   C
   o---o  feature1
        \
         D
         o  feature2

```

### Merging `feature1`

Let's say that we are now ready to merge in our `feature1` branch, but first we will squash our two commits into one.  Once we've squashed, we'll merge into `master`. Also, as a matter of clean up, we'll delete our `feature1` branch as we don't need it any more.

```
git checkout feature1
git rebase -i HEAD~2

git checkout master
git merge --no--ff feature1

git branch -d feature1
```

The resulting git history will look like this:

```
 A   E
 o---o  master
  \
   B   C   D
   o---o---o  feature2

```

As we can see, it now looks like our `feature2` branch has three commits different from `master`. Additionally, our master branch has now moved on.

### Rebasing `feature2`

What we'd like to do at this point is rebase our `feature2` on `master` and end up with only one commit, D, in our branch, which is our unique change. Our desired history would look like:

```
 A   E
 o---o  master
      \
       D
       o  feature2

```

Normally to achieve this we would just `git rebase master`, however, since the history for `feature1` was rewritten we'll get merge conflicts.

Instead, we can use the [--onto option](http://git-scm.com/docs/git-rebase#_options) for our rebase. Using `--onto` we can specify our `<newbase>`, `master`, and the `<upstream>` to compare against for the rebase.

```
git rebase --onto <newbase> <upstream>
```

When doing a default rebase the `<upstream>` will be the first commit where the branch diverged from the base branch, `master`. In our case that would be the first commit from the old `feature1` branch, or, B.

What we want to do is tell git to ignore the two commits from `feature1`, B and C, and only rebase our commit, D, onto `master`. To do this, we pass the SHA for D as the `<upstream>` option like this:

```
git checkout feature2
git rebase --onto master HEAD~1
```

In addition to `HEAD~1`, we could have passed an actual SHA `6f74799` or any other way of referencing the commit we wanted to start from.

I will note that the commit you specify in the `<upstream>` option will be included in the rebase. This is different from how an [interactive rebase](http://git-scm.com/docs/git-rebase#_interactive_mode) works.

### Notes

This way of rebasing expects that you can determine where `feature1`'s history ends and `feature2`'s history begins. If that is not possible then you might want to consider strategies for labeling the first commit of your branch, or not deleting merged branches right away.

This post builds on the "hard case" of recovering from an upstream rebase which you can read about in the [docs for git rebase](http://git-scm.com/docs/git-rebase#_recovering_from_upstream_rebase).
