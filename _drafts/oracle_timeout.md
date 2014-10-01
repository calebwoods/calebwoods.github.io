---
layout: post
title:  "Oracle DB connection hanging in Ruby"
date:   2014-09-30 17:15:00
---

A couple weeks ago on my main project I came across a database issue that I'd never seen before and wanted to document it here in case anyone else runs into a similar issue.

### The Problem

Our stack it is a Ruby on Rails API using the Sequel gem to connect to Oracle 11.2 database deployed with Unicorn and nginx.

Started to notice that some times when accessing our app, requests would hang for 60 seconds and then return a 504 from nginx.  This error means that nginx wasn't getting a response from Unicorn.  It's also important to note that issue only show if after 60 minutes of inactivity on the app.

### The Diagnosis

As a first step we investigated the logs, however, the only thing we found was the Unicorn was killing hung works that correlated with the 504 errors.

To further debug the issue we deployed increased logging to API so that we could see where app was hanging.  From this it was possible to see that it was querying the DB that was hanging.

### Firewall

Turns out that there was a firewall in our production environment that was configured to kill inactive TCP connections after 60 minutes inactivity.  The problem is that when the firewall kills the connection the Oracle Instant Client can't see that the connection isn't valid anymore.

### Duplicating locally

To make it easier to diagnose the issue I used iptables on Vagrant VM of Oracle to reproduce the dropping of packets.

```
iptables -A INPUT -p tcp --dport 1521 -j DROP
```

### Solutions

To prevent the firewall from killing the connection we can set `SQLNET.EXPIRE_TIME` value which will check that connect is valid every X number of minutes.

Additionally we can set `SQLNET.RECV_TIMEOUT` value which specifies the number seconds to wait for response from the DB. By setting this value we will get an exception logged.

**OCI8** Connection Pool

### Conclusion

Always know what environment you are deploying in and use those tools to help diagnose.
