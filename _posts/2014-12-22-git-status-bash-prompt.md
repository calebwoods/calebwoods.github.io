---
layout: post
title:  "Git Status in Your Bash Prompt"
date:   2014-12-22 12:15:00
---

Over the past few weeks I've been pairing with several different developers and have gotten some questions about the prompt that I use for Bash, which includes some git information.

![Bash Prompt Example](/images/bash_prompt.png)

So what is all of that information? `~/code/personal/calebwoods` is the current path for the shell and is always displayed.  The information within the parans is the git information, which is only shown when in a git repository.

### Minutes Since Last Commit

This number shows how long it has been in minutes since a commit was made to the current branch.  This idea was taken from Gary Bernhardt's [dotfiles](https://github.com/garybernhardt/dotfiles/blob/master/.bashrc).  I use it as reminder to ensure commits are happening frequently.

### Current Branch

The text after the `|` indicates the current git branch.  This is pretty common and probably doesn't need much explanation.

### Color

In the prompt example, you'll notice that the git portion has a different color.  This color is based on the working directory status.

* Green: no changes, everything committed
* Yellow: changes, everything staged
* Red: changes, unstaged changes

To do this calculation I have a `_git_color` function in my bash profile.

```bash
GREEN='\e[0;32m';
YELLOW='\e[1;33m';
RED='\e[1;31m';

function _git_color() {
  `command git branch > /dev/null 2>&1`; if [ $? -eq 0 ]; then
    clean=`command git status | grep "nothing to commit" | wc -l`
    if [ "$clean" -eq "1" ]; then
      echo $GREEN; else # clean working directory
      stagged=`command git status | grep "not staged for commit" | wc -l`
      if [ "$stagged" -eq "1" ]; then
        echo $RED; else # unstagged changes
        echo $YELLOW; # all changes stagged
      fi;
    fi;
  fi;
}
```

### Putting It All Together


Note that the `\e[00m` color code is needed to terminate the color of prompt.

```bash
NORMAL='\e[00m';
PS1='\n\w$(__git_ps1 " (`_git_color``minutes_since_last_commit`|%s$NORMAL)")\n\$ '

```

This results in a prompt that looks like the following:


```

~/code/personal/calebwoods (12|source)
$
```

Have your own prompt tips for seeing git information in your prompt? Contact me, I'm always looking for ways to improve mine.
