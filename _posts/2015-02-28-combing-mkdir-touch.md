---
layout: post
title: "Combining mkdir -p and touch"
date: "2015-02-28"
tags:
  - bash
  - scripting
---

As a developer, I often use the unix [touch](http://man7.org/linux/man-pages/man1/touch.1.html) command to create files.  One thing that I've always wished `touch` would do is automatically create intermediate directories.  Because it doesn't do that, if I want to create `foo/bar/baz.txt` in an empty directory I need to use the following commands.

```bash
$ mkdir -p foo/bar
$ touch foo/bar/baz.txt
```

Because I type these commands enough I decided to write a function to stick in my Bash config to combine these commands and invoke it using `touch`.  Here is what I came up with.

```bash
# .bashrc
touch () {
  mkdir -p "$(dirname "$1")"
  command touch "$1"
}
```

With this I can call `touch foo/bar/baz.txt` and the directories `foo` and `bar` will be created in addition to the file `baz.txt`.

```
$ touch foo/bar/baz.txt
$ tree foo
foo
└── bar
    └── baz.txt

1 directory, 1 file
```

Something new for me was using `command` utility to call the OS's default `touch` command when we are overriding it.

I'm looking forward to saving some key strokes with this function.  Have some custom Bash functions you use all the time?  Tweet at me [@calebwoods](http://twitter.com/calebwoods), would love to hear your time saving tips.
