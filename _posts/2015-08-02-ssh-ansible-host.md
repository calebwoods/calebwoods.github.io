---
layout: post
title: "SSH to Ansible host by hostname"
date: "2015-08-02"
tags:
  - linux
  - bash
  - ansible
  - scripting
---

For my current project we have [Ansible](http://docs.ansible.com/) deploy scripts for our handful of services to a set of development servers.  This has generally worked well, but occasionally we need to SSH directly to the server to debug an issue.  Ideally I'd like to SSH to a server via it's Ansible hostname rather than having to look up its IP or machine name.

To my knowledge this doesn't exist out of the box with Ansible, so I set about writing a simple Bash function to serve this purpose.

Note that I'm working with a few assumptions:

1. The SSH user for each host is that same, `ansible` in my example.
2. The hosts are defined in the [default location](http://docs.ansible.com/ansible/intro_inventory.html) `/etc/ansible/hosts` or a file ending in `hosts` under the current working directory, e.g. `provisioning/ansible_hosts` or `provisioning/hosts`.
3. Assumes SSH connection on port 22.

### Script

In `~/.bashrc`:

```bash
ansible-ssh() {
  if [ -z "$1" ]; then
    echo "No hostname specified"
    echo "usage: ansible-ssh [hostname] [user=ansible]";
    return 1;
  fi
  if [ -z "$2" ]; then
    USER="ansible"
  else
    USER="$2"
  fi

  if [ -e '/etc/ansible/hosts' ]; then
    DIRECTORIES='/etc/ansible .'
  else
    DIRECTORIES='.'
  fi

  INVENTORY=`find $DIRECTORIES -name '*hosts' | xargs`
  HOST=`cat $INVENTORY | grep -A 1 "\[$1\]" | tail -1`
  command ssh "$USER@$HOST"
}
```

Adding this to my bash config I can create an SSH session with the following:

```
$ ansible-ssh testhost
```

To SSH with a specific user, just pass the user as the second argument:

```
$ ansible-ssh testhost devuser
```

I'm sure there may be more efficient ways to parse the hosts file and I'm open to suggestion for improvement, but this has already been a time saver.

For a future version I'd like to extract to proper binary, instead of a bash function, and add some more features including:

* Support for non standard SSH port
* Support for dynamic inventories
* Configurable default user

Have other ways you've leveraged ansible artifacts to make dev tasks easier? Tweet at me [@calebwoods](https://twitter.com/calebwoods).
