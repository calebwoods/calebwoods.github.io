---
layout: post
title: "Navigate by Word in iTerm2"
date: "2017-02-23"
tags:
  - workflow
  - terminal
---

A natural flow that I've gotten used to over the years is using the option key (&#8997;) combined with the arrow keys to navigation between word boundaries in simple text editors.  I also use this to quickly delete a word at a time rather than holding down the delete key.

Given this muscle memory, I was surprised that when I started using [iTerm2](https://www.iterm2.com/) that this functionality wasn't supported out of the box.  Especially since this is standard in the default Terminal app.

![Navigate by word example](/images/iterm2/navigate_by_word_example.gif)

Below are the instructions needed to enable this behavior.

### Settings

Open up your default profile and go to the Keys section and ensure that your option keys (&#8997;) are set to act as +Esc.

![Keys Profile section](/images/iterm2/keys_section.png)

Then create 2 new key mappings.  One for option (&#8997;) + left arrow (&larr;) to send the escape sequence `b` and another for option (&#8997;) + right arrow (&rarr;) to send the escape sequence `f`.

![Back Escape Sequence Example](/images/iterm2/back_sequence.png)
![Forward Escape Sequence Example](/images/iterm2/forward_sequence.png)

### Bonus

To avoid having to do this again next time you setup a new Mac I highly recommend using the "Load preferences from a custom folder or URL" feature and syncing that with a tool like Dropbox.


![Dropbox Sync Settings](/images/iterm2/sync_settings.png)

### Always Learning

Would be curious to hear what ways you've customized your terminal experience to add "creature comforts" or increase your productivity.  You can reach me on Twitter at [@calebwoods](https://twitter.com/calebwoods).
