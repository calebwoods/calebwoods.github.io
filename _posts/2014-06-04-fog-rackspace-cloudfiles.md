---
layout: post
title:  "Fog and Slow Rackspace Cloud Files Requests"
date:   2014-06-04 21:15:00
tags:
  - ruby
  - debugging
---

Today I was working on fixing a performance bug for a project that uses the [Fog gem](https://github.com/fog/fog) to access [Rackspace's Cloud Files](http://www.rackspace.com/cloud/files/) API, and I made an interesting discovery that seemed worth sharing.

For some background, the app I was working on has an API that accepts small image files that can be associated with each record. These images will then be returned with the record when accessed through the API.

The issue I was having was that API requests to retrieve those records with the associated images were taking a really long time, especially the internal request to Cloud Files. This was strange as the images are only 5-15kb and Cloud Files and the app servers are located in the data center for this app.

Doing some searching to see if others were having this problem, I came accross this [Github issue](https://github.com/fog/fog/issues/2714) which helped me track down the problem area.

In our app we had the following method to retrieve files:

```ruby
def remote_file(directory_name, file_name)
  directory = connection.directories.get directory_name
  directory.files.get file_name
end
```

This looks like a fine solution that many Fog examples use, however, there lies a critical performance issue in this code.  

As the [Fog Rackspace documentation](https://github.com/fog/fog/blob/master/lib/fog/rackspace/docs/storage.md#get-directory) points out, using `directories.get` will indeed return the directory.  But it also returns the meta data for the first **10,000** files in that directory. In our case the directory had over 10,000 files so we were returning all that extra meta data for every file retrieval.

Thankfully, there is an easy solution. Just switch the code to use `directories.new`, and problem solved.

```ruby
def remote_file(directory_name, file_name)
  directory = connection.directories.new key: directory_name
  directory.files.get file_name
end
```

In debugging this issue I am again reminded of the value of analyzing how a new library works when adding it to your project.  Just because code works when you bring in a gem doesn't mean you shouldn't throughly test and examine the side affects.

On a side note, it is great to see that the community has improved the documentation regarding this issue. [Looking back](https://github.com/fog/fog/blob/8c1319703d77139c7f3b249c0bb105b975e6b5e0/lib/fog/rackspace/docs/storage.md#get-directory) there was no information regarding `get` vs `new` when I first wrote that method.
