---
layout: post
title: "Running Commands on Vagrant Guest from Host"
date: "2015-05-05"
tags:
  - linux
  - bash
  - ruby
  - scripting
---

Recently, I've been working on converting several development environments to [Vagrant](https://www.vagrantup.com/) VMs, in order to speedup setup time when bringing in new developers and making environment changes.

A few years ago I wrote a tool, [Shoestring](https://github.com/calebwoods/shoestring), to help make writing bootstrapping scripts for development environments easier.  I quickly discovered that what I really wanted was a full provisioning tool that could start with a near empty machine. Couple that experience with the fact that I've been using [Ansible](http://www.ansible.com/home) for the past couple of years and writing my own tool seemed like overkill.

### Potential Solution

With Ansible and Vagrant it is pretty straightforward to create a development environment that can be built with the simple command `vagrant up`.  Additionally, the environment can more closely mirror production with the same OS and shared provisioning scripts.

One of my biggest issues with a Vagrant setup was that to run any commands, such as unit tests or a development server, one would have to ssh into the VM.  Then once in the VM all of my aliases and shortcuts are no more, and I would need to toggle back and forth between the VM and my local machine for things like git.

### vagrant ssh -c

While looking at the [Vagrant documentation](https://docs.vagrantup.com/v2/cli/ssh.html), however, I found the `-c` option which can be passed to `vagrant ssh`.  With this, a command can be specified as a string and sent over ssh to the guest VM then executed with all output re-routed to the host machine's stdout and stderr.

This means to run the rspec test suite for a project I would just need the following:

```
$ vagrant ssh -c 'cd /vagrant; bundle exec rspec'
```

Even cooler is that if you have a debugger in your specs, such as [Pry](http://pryrepl.org/), you can still interact with the repl like you would if it were running on your local machine.

### More Awesome-Sauce

Then I realized I have an alias that I use to run `bundle exec` commands by just using `b`.  For example:

```
$ b rspec
```

So I created `v` and `vb` shortcut functions. This allows me to just add one character to the above rspec command and it will run on the guest VM instead.

```
$ vb rspec
```

All that is needed is adding the following functions to your `.bashrc`.

```bash
# .bashrc

# Execute commands on Vagrant remote
vb() {
  CMD="cd /vagrant; bundle exec $@";
  vagrant ssh -c "$CMD"
}

v() {
  CMD="cd /vagrant; $@";
  vagrant ssh -c "$CMD"
}
```

With these functions I've found working with Vagrant development environment to be so much more enjoyable and seamless.  Have other improvements to your own Vagrant workflow? Tweet at me [@calebwoods](https://twitter.com/calebwoods).
