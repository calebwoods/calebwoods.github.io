---
layout: post
title: "APIs for Large Collections"
date: "2015-10-04"
tags:
  - api
---

One hallmark of these spreadsheet replacement type business applications is that they need to display, sort, and filter large collections of complex data structures.  For example let's consider the backend system for an eCommerce application a view of orders.  

You will have thousands of orders, making it impossible to display everything on a single page or payload from the API if you want performance to scale.  This means be some kind of pagination will need to be implemented on server.

For filtering and sorting there are few options depending on the type of API client.

### Chatty API

With a "chatty" API you will keep the operations of sorting and filtering on the server.  This makes for a pretty dumb client and it can easily interact with small amounts.

If using a JS frontend you'll have to build full featured filtering on API side and a client that can maintain the context in JS.

This really requires that the application will need to be connected to the network to work, as not enough data will exist for offline use.

### Syncing API

If offline use and complex client side filtering and sorting of data are you required you may want to consider a "syncing" API.  Instead of constantly making requests for data on the server, data is synced to the client and cached locally.  This is often used for mobile applications and could be a good for APIs serving multiple rich clients.

The drawback is that before the applicaiton can full function it will have to sync all the data from the server.  This can present challenges as datasets grow.
