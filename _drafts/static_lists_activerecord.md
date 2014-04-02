---
layout: post
title:  Static Lists with ActiveRecord
date:   2014-04-02 10:58:54
---

In the dozens of web applications I've built there seems to be a common pattern with an evolving solution, static lists. These could be thinking like States for address, name prefixes, user roles. I'd like to take a look at three solution to solve this problem for a Rails app.  For the purposes of this post we'll use the example of a Person object with a list of greetings: Hi, Hello, Dear, Other.

```ruby
class Person < ActiveRecord::Base
end
```

### Database Table

In a Rails app adding new table is any easy thing to do and make adding new greetings to list very straight forward. If we implemented a Greeting ActiveRecord object we might end up with some code like this.

```ruby
# app/models/person.rb
class Person < ActiveRecord::Base
  belongs_to :greeting

  validates :greeting, presence: true

  delegate :value, to: greeting, prefix: true
end

# app/models/greeting.rb
class Greeting < ActiveRecord::Base
  has_many :people

  validates :value, presence: true, uniqueness: true
end
```

Simple enough to implement, so what are the pro/cons on this solution.

* Pros
  * Easy to implement
  * Add more greetings without redeploying app
* Cons
  * Person tests will require Greeting object to be created
  * Displaying form options from table would be another query
  * Other option is not yet supported

### Module

This concept of a greeting and it's related validations is really a single concept and would be nice to issolate it's implementation in case was need else where. Also because this list is not expected to change much if ever we like to not have to query the database to get the list or the display the value set on Person.

```ruby
# app/models/person.rb
class Person < ActiveRecord::Base
  include Greeting
end

# app/models/static_value.rb
StaticValue = Stuct.new(:id, :value)

# app/models/concerns/greeting.rb
module Greeting
  extend ActiveSupport::Concern

  Hi    = StaticValue.new(1, 'Hi')
  Hello = StaticValue.new(2, 'Hello')
  Dear  = StaticValue.new(3, 'Dear')
  Other = StaticValue.new(4, 'Other')

  Collection = constants.map do |const_sym|
    const_get(const_sym)
  end
  FormOptions = Collection.map do |greeting|
    [ greeting.value, greeting.id ]
  end
  All = Collection.map(&:id)

  included do
    validates :greeting_id, presence: true,
                            inclusion: { in: Greeting::All }
  end

  def greeting
    Greeting::Collection.detect do |greeting|
      greeting.id == greeting_id
    end
  end

  def greeting_value
    if greeting == Greeting::Other
      greeting_other
    else
      greeting.value
    end
  end
end
```

This is admititly more code, but we've also got some more features. In this version we've implement support for an `greeting_other` database column which could custom greetings entered by user. We've also added the `FormOptions` constant which can be used in a form builder to build dropdown options. Most importantly we make zero database calls to get these values which means faster tests and application. In addtion because we are storing ids on Person object it would straight forward to move the Database Table pattern if needed in the future.

* Pros
  * No database queries
  * Easier test setup
  * Supports form builders
  * Used with any ORM
  * Easy to convert to table
  * Support `Other` option
* Cons
  * Changes require redeploying application
  * More lines of code

### Enums

The module pattern I've shown above is similar to the [enum](http://en.wikipedia.org/wiki/Enumerated_type) support that many programming languages have. While Ruby doesn't have native support enums it's a new [feature](http://edgeguides.rubyonrails.org/4_1_release_notes.html#active-record-enums) in Rails 4.1. Let's take a look at what implemenation using enum would look like.

```ruby
class Person < ActiveRecord::Base
  enum greeting: [ :hi, :hello, :dear ]

  validates :greeting, presence: true

  def greeting_value
    greeting.capitalize
  end
end
```

Using the new ActiveRecord enums has the advantage of creating dynimic like `hi!` and `hi?` to set and check the value. Unfortunately I'm not seeing form helper integration in 4.1.0.rc2. However this is a very small about of code to have to write and our `greeting_value` method is only a convience to make value look correct in a UI.

* Pros
  * Simple implementation
  * Dynamic method creation
  * No database queries
* Cons
  * Change require redeploying application
  * No form builder support

### Conclusion

As compare these options they each have situation where they shine. A database table is create to make changes fast, the module pattern is flexible with good support of intraspection, enums is simple and gives short cut methods. With that said I've found that module pattern is a good place, however, I'll be curious to see how [ActiveRecord enums](http://edgeguides.rubyonrails.org/4_1_release_notes.html#active-record-enums) evolves over time. If you'd like to compare these implementation in more depth I've put together a [sample app](https://github.com/calebwoods/static_lists_post) with tests.

