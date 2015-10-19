---
layout: post
title: "Choosing a Frontend for Form and Data Heavy Applications"
date: "2015-10-19"
tags:
  - rails
  - ruby
  - angularjs
  - api
---

Recently, I've been building several form and data heavy business applications for clients.  Most of these applications have lots of basic CRUD features on top of some special business rules or interactions with other systems.

In experimenting with different stacks, including some full Javascript frontends with Angular, I've come up with the following set of considerations for when a full Javascript frontend may not be the right fit.

### Shaping Data

One benefit of doing a full Javascript SPA (Single Page Application) as a frontend is that it requires you to build a robust API for your application.  I've found that this is a good constraint for defining the interface of your application and serves as a great point in the stack for integration testing.

When building your API you'll want to have a method of serializing the data for the API.  This becomes a challenge when the same objects need to be represented differently depending on context.  In some case you may need to display all attributes of an object and in others, such as a form dropdown, just the id and name.

This presents the problem of how to structure your API so that you are sending the smallest amount of data possible for optimal performance. Do you have different endpoints? Optional parameters in your endpoints?

Netflix ran into this problem when trying support varying clients with the same REST API.  Instead of adding more complexity to the API they created a [system for client teams to build their own custom endpoints](http://techblog.netflix.com/2013/01/optimizing-netflix-api.html).

Another option is the use of projections, such as on the [Eve Python project](http://python-eve.org/config.html#projection).  It allows the client of the API to define what attributes are returned in a response via a whitelist or blacklist.

```
# Only return lastname
$ curl -i http://eve-demo.herokuapp.com/people?projection={"lastname": 1}

# Return everything but lastname
$ curl -i http://eve-demo.herokuapp.com/people?projection={"lastname": 0}
```

The Netflix approach may not be the easiest solution to implement for smaller applications, but considering how data will be dynamically serialized is something that will need to be tackled.  Putting all the control on client using something like projections may be useful, but it also encodes a lot of knowledge into the client.

### Multiple Environment Complexity

Having different server and client environments creates some duplication of rules and the domain that will need to exist.  You'll also need to keep more interactions loaded in your mental model when working on a feature.

For example, consider that to add an "update" feature for an object in a standard Rails you would need to edit 3-4 files (Model, View, Controller, Routes), with a rich Javascript frontend you will now need to change 7-8 files (Server: Model, Serializer, Controller, Routes, Client: Model, View, Controller, Routes).

### Forms

One thing that I've missed with Javascript frontends is the Rails form builder.  Because it integrates with a backing form object it can integrate validations, automatically determine input types, and abstract away markup with a library like [simple_form](https://github.com/plataformatec/simple_form).

Having to go through the serialization step means you will need additional logic to integrate errors. Large forms with nested data structures is where this pain is felt the most.

Either way you go, you'll need to consider client side validations and how to handle dynamic form controls, which for some cases can be easier with a rich client.

### Browser Support

While it won't affect all applications, older browser support is something to consider.  Most of the world has moved on from older versions of Internet Explorer, but many large enterprises are still running Windows XP and thus locked into IE8.

Angular's support of these browsers has not been great with IE8 support dropped in 1.3 and Angular 2 is [only supporting "evergreen" browsers](http://angularjs.blogspot.com/2014/03/angular-20.html).

Other Javascript frameworks like Ember and React have a similar story.  If you need your application to at least work in a limited mode on those browsers you might need to consider how fallback will work (or not work) with a full Javascript frontend.

### Managing Trade Offs

The challenges mentioned above are trade offs that should be considered when deciding on the stack for a modern web application in 2015.  Building a full Javascript frontend is not the only option.

I'm starting to explore more options for mixing in Javascript with a progressive enhancement mindset rather than all or nothing.  Partly to increase browser support, but also to make building these types of business applications as productive as possible by leveraging the best tools for the situation.

On future projects I plan to experiment with leveraging the latest version of [Turbolinks](https://github.com/rails/turbolinks) which uses the browser's PushState API to reload the DOM without recompiling CSS and JS, but can fallback to full page loads when needed. I also plan to explore  ways to build smaller SPAs or Javascript components within a server side application, rather taking the all or nothing approach.

Javascript only frontends have their place, but from my recent experience the sweet spot is not **yet** these form and data heavy business applications.
