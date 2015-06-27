---
layout: post
title: "Mixing Ansible Roles and Tasks"
date: "2015-06-27"
tags:
  - linux
  - bash
  - ansible
  - server
  - scripting
---

Over the past couple of weeks I've been working on refactoring [Ansible](http://docs.ansible.com/) deploy scripts for a client where we are deploying several [Rails](http://rubyonrails.org/) based services.

Most of this refactor has been pulling common tasks like setting up [unicorn](http://unicorn.bogomips.org/) and [nginx](http://nginx.org/) into distinct roles.  Here is a condensed example playbook:

```yaml
---
- hosts: all

  pre_tasks:
    - name: upgrade packages
      apt: upgrade=yes update_cache=yes cache_valid_time=300
      sudo: yes

  roles:
    - { role: brightbox_ruby, ruby_version: 2.2.2 }
    - { role: deploy_code,
        git_branch: master,
        repo: 'https://github.com/calebwoods/myapp',
        ruby_env_template: 'templates/production_env.rb' }
    - { role: unicorn }
    - { role: nginx, nginx: { app: 'myapp' } }
    - { role: sidekiq, apps_dir: '/var/www' }

  post_tasks:
    - name: setup log rotation
      sudo: yes
      template: src=templates/logrotate.conf dest=/etc/logrotate.d/myapp.conf
```

In this playbook there are a few `pre_tasks` which will run before all the roles.  This is useful to get the state of the machine ready for the rest of the playbook such as updating the base packages or installing specific application dependencies. `post_tasks` or `tasks` can be used for after the roles have run for similar types of tasks.

### Interleaving commands

The challenge when refactoring these playbooks was where to put commands like `bundle install` or `rake db:migrate`.  These are fairly common and require that prerequisite roles have been executed, such as Ruby being installed.  In addition, later roles like, unicorn and sidekiq, require that those commands have already been run.  Typically these would be done with tasks, but Ansible only gives you the option of running tasks before or after roles.

Additionally, some applications will have rake tasks or other one off commands that need to be run inbetween roles such setting up [Cron jobs](https://en.wikipedia.org/wiki/Cron) with [whenever](https://github.com/javan/whenever), `bundle exec whenever --update-cron`.  So for these reason it would be nice if there was a general solution rather than having to create a new role for every special case.

### Simple solution

The solution I came up with was to create an Ansible role for running one off bash commands, called [bash_command](https://github.com/RoleModel/bash_command).

The role has two simple inputs: `command` and `dir`. `command` is the string you want to run and can include interpolated Ansible variables.  The command will be using `bash -lc` through the `shell` module to run the command which means it runs in a login bash shell, so you will have access to any ENV variables that have been set elsewhere in your playbook.  The `dir` input specifies where to `cd` into before running the `command`.

Here is an example of how the roles section of my playbook would be structured for a Rails application using bundler, [whenever](https://github.com/javan/whenever), database migrations, and precompiling assets:

```yaml
roles:
  - { role: brightbox_ruby, ruby_version: 2.2.2 }
  - { role: deploy_code,
      git_branch: master,
      repo: 'https://github.com/calebwoods/myapp',
      ruby_env_template: 'templates/production_env.rb' }
  - { role: bash_command,
      command: 'bundle install --binstubs bin --without development test --deployment --path vendor/bundle',
      dir: '/var/www/myapp' }
  - { role: bash_command,
      command: 'bundle exec whenever --update-cron',
      dir: '/var/www/myapp' }
  - { role: bash_command,
      command: 'bundle exec rake db:migrate',
      dir: '/var/www/myapp' }
  - { role: bash_command,
      command: 'bundle exec rake assets:precompile assets:clean',
      dir: '/var/www/myapp' }
  - { role: unicorn }
  - { role: nginx, nginx: { app: 'myapp' } }
  - { role: sidekiq, apps_dir: '/var/www' }
```

Have other tricks you've used to create more reusable Ansible scripts? Tweet at me [@calebwoods](https://twitter.com/calebwoods).
