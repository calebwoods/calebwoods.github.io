---
layout: post
title:  "Angular.js, IE9, CORS, and Nginx"
date:   2014-03-22 10:58:54
---

In this post I'll share an example on a recent Angular.js application I worked on which needed to support Internet Explorer 9 and connect to multiple remote APIs.

The issue with this setup is that by default browers prevent any Javascript on the page from making requests to another domain. This is done to prevent [Cross Site Scripting]()**. While this is a good safety measure as application developers it can be common to have a backend API hosted a subdomain such as `api.example.com` and have the frontend Javascript application hosted on separate domain like `frontend.example.com`.

### JSONP

[JSONP]()** is another option that many popular API expose for Javascript clients. With JSONP the server will respond with a Javascript body which includes function callback which was specified in the request. We should not that a JSONP only supports GET requests which is how it get around the Cross Site Scripting issue.

This works pretty well APIs that server Javascript client, but unfortunately it means you will have a different API format for mobile clients of API.

### Cross Origin Request Sharing

Thankfully there is a solution for modern browers called [Cross Origin Request Sharing]()** or CORS for short. CORS allows Javascript application to make requests to a server that returns the proper CORS headers.

Internet Explorer 9 and below, however, do not support CORS which for our example is a problem.

### Proxies

A server side proxy for our API however allows us to solve this issue. With a proxy can let the server forward requests to the other subdomain and to the browers it looks like it is calling the same server.

This means we could have a request like `frontend.example.com/api/items.json` forwarded to `api.example.com/items.json`. Which will work for us it all browsers.

### Development

Grunt Proxy

### Production

Nginx

### Multiple Proxies


### When well

* HTML5 mode fallback worked great, link between browsers work
* Microsoft VMs to test versions
  * alias 10.0.2.2 to localhost

### Changes to make

* Proxy APIs
  * No CORS support
  * Example nginx conf
* File uploads
  * flash fallback

### Issues

* Debugging random error messages
  * Firebug lite

### Future

* Test sooner
* Test on regular basis
