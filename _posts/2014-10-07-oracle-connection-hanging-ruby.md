---
layout: post
title:  "Oracle connection hanging in Ruby"
date:   2014-10-07 17:15:00
---

Recently, I came across a database issue on a client project  that I'd never seen before, so I wanted to document it here incase anyone else runs into a similar issue.

### The Problem

The stack was a Ruby on Rails API using the [Sequel](https://github.com/jeremyevans/sequel) gem to connect to an Oracle database deployed with [Unicorn](http://unicorn.bogomips.org/) and [nginx](http://nginx.org/).  This API also had an [Angular.js](https://angularjs.org/) client that was connecting to it.

Users started to notice that when accessing the app the requests would sometimes go on indefinitely. Looking into the logs, we were able to see that the Unicorn workers were killed after 60 seconds, resulting in nginx returning a 504 to the client.

An important detail that took us a while to figure out was: this issue would only happen if the Unicorn worker handling the request had been idle for more than 60 minutes.

### The Diagnosis

As with most errors, the first step was to examine the logs to determine what the error might be, however, because the worker's process was hanging and being killed by Unicorn there were no errors in the Rails logs.

To further debug the issue we deployed increased logging to the API around the endpoint where we had seen the error so that we could see where app was hanging.  This made it possible to see that the app was querying the Oracle database when it was hanging.

### Firewall

This application was deployed into a infrastructure controlled by our client. Upon finding that the connection to the database was the issue, we began examining the part of the infrastructure that sat between our app and the database.

As it turned out, there was a firewall in our production environment that was configured to kill inactive TCP connections after 60 minutes of inactivity, a fairly common security measure to limit inactive connections.  The issue for our app was that when the firewall killed the connection the Oracle Instant Client couldn't see that the connection wasn't valid and still tried to use it.

Unfortunately, the way the firewall killed the connection created a kind of "black hole" were when querying using the Oracle client it seemed that the server got the request and it was just waiting for a response. This is due to the fact that the firewall would drop all packets after the connection was killed.

### Duplicating Locally

To make it easier to diagnose the issue I used iptables, a common software firewall, on a Vagrant VM running Oracle to reproduce the dropping of packets.

```
iptables -A INPUT -p tcp --dport 1521 -j DROP
```

### Solutions

Once I was able to duplicate the issue we could then try several solutions to solve the problem.

To prevent the firewall from killing the TCP connection we set a `SQLNET.EXPIRE_TIME` value in sqlnet.ora which has the Oracle client check that the connection is valid every X number of minutes. We set that check at less than 60 minutes so that the firewall's inactive threshold will never be met.

Additionally, we set a `SQLNET.RECV_TIMEOUT` value in sqlnet.ora which specifies the number of seconds to wait for a response from the database. By setting this value we will get an exception logged if a response does not come back before the timeout.

### Conclusion

Getting to the bottom of this issue definitely reminded me of the value in knowing how to debug code through the entire stack of the project. While many can be found in code, some bugs are specific to the environment configuration and would not be found in development unless there was a mirrored environment.
