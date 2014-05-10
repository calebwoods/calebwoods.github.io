---
layout: post
title:  "Angular.js, IE9, CORS, and Nginx"
date:   2014-05-10 17:15:00
---

In this post I'll share an example of a recent Angular.js application I worked on which needed to support Internet Explorer 9 and connect to multiple remote APIs.

The issue with this setup is that by default the browser prevents any Javascript on the page from making requests to another domain. This is done to prevent [Cross Site Scripting](http://en.wikipedia.org/wiki/Cross-site_scripting). While this is a good safety measure, as application developers it can be common to have a backend API hosted on a subdomain such as `api.example.com` and have the frontend Javascript application hosted on separate domain like `frontend.example.com` which cause an issue of how to connect to the API.

### JSONP

[JSONP](http://en.wikipedia.org/wiki/JSONP) is an option that many popular APIs expose for Javascript clients. With JSONP, the server will respond with a Javascript body which includes a function callback as specified in the request. We should note that JSONP only supports GET requests and uses `<script>` tags to get around the Cross Site Scripting issue.

This works pretty well with APIs that serve Javascript clients, but unfortunately it means you will have a different API format for mobile clients of the API.

### Cross Origin Request Sharing

Thankfully there is a solution for modern browsers called [Cross Origin Request Sharing](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing), or CORS for short. CORS allows Javascript applications to make requests to a server that return the proper CORS headers.

As it is, though, Internet Explorer 9 and below do not support CORS, which is a problem for our example.

### Proxies

A server side proxy for our API, however, does allow us to solve this issue. With a proxy we can let the server forward requests to the other subdomains, and to the browser it looks like it is calling the same server.

This means we could have a mapping of request like below which works in all browsers.

```
frontend.example.com/api/items => api.example.com/items
```

### Development

In development, setting up your proxy is pretty simple using [grunt-connect-proxy](https://github.com/drewzboto/grunt-connect-proxy). You will just need to add proxy section to your `Gruntfile.js`, similar to the example below.

```js
connect: {
    ...
    server: {
        proxies: [
            {
                context: '/api1',
                host: 'localhost',
                port: 4000,
                https: false,
                changeOrigin: false,
                rewrite: {
                    '^/api1': ''
                }
            },
            {
                context: '/api2',
                host: 'localhost',
                port: 4100,
                https: false,
                changeOrigin: false,
                rewrite: {
                    '^/api2': ''
                }
            }
        ]
    }
}
```

For more information on options with [grunt-connect-proxy](https://github.com/drewzboto/grunt-connect-proxy), check out [this](http://fettblog.eu/blog/2013/09/20/using-grunt-connect-proxy/) blog post.

### Production

We deployed our Angular application with Nginx as a web server to serve static files. In addition to static files, Nginx has great support to proxy to other web servers.  For our APIs we just need to add some location directives to the `nginx.conf` file like the example below.

```nginx
location /api1 {
  rewrite ^/api1/(.*) /$1 break;
  proxy_redirect off;
  proxy_pass https://api1.example.com;
  # ...
}

location /api2 {
  rewrite ^/api2/(.*) /$1 break;
  proxy_redirect off;
  proxy_pass https://api2.example.com;
  # ...
}
```

To see a full example of the Nginx config, take a look at [this gist](https://gist.github.com/calebwoods/5e88b5e323d55ad71195).

### Take Aways

Decide on which browsers to support early on in your project. Also make sure that you are running tests frequently in development and production with the browsers you will support.

If on the Mac and developing to support Internet Explorer, I highly recomend checking out Microsofts collection of prebuilt [Virtual Machine images](http://www.modern.ie/en-us/virtualization-tools) to use in testing.
