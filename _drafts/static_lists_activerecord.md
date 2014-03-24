---
layout: post
title:  Static Lists with ActiveRecord
date:   2014-03-22 10:58:54
---

### Example

```ruby
class Person < ActiveRecord::Base
  # Prefix
end
```

### Database Table

* Need to change without redeploying app
* Slower

### Module

* Little or no change
* Redeploying is not a problem
* Easy to convert to table if neeeded
* Encapsulated in a module
* Used with any ORM

### Enums

* Built in to Rails 4
* Special methods?
* Form helper?
