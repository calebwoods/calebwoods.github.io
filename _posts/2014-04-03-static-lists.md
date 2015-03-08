---
layout: post
title:  "Static Lists: Database Table, Module, or Enums"
date:   2014-04-03 20:00:00
tags:
  - ruby
  - rails
  - database
---

In my experience building web applications I have seen the need for a pattern to solve the problem of static lists. By static lists I mean things like: US states, name prefixes, roles, etc.

For comparison we will look at three solutions to solve this problem for a Rails app. Our example will be a `Person` object with a list of greetings options: Hi, Hello, Dear.

```ruby
class Person < ActiveRecord::Base
end
```

### Database Table

In a Ruby on Rails application, adding a new database table is easy and makes adding new greetings to a list very straightforward. If we implemented a `Greeting` ActiveRecord object we might end up with some code like the following.

```ruby
# app/models/person.rb
class Person < ActiveRecord::Base
  belongs_to :greeting

  validates :greeting, presence: true

  delegate :value, to: :greeting, prefix: true
end

# app/models/greeting.rb
class Greeting < ActiveRecord::Base
  has_many :people

  validates :value, presence: true, uniqueness: true
end
```

#### Pros
* Easy to implement
* Can add more greetings without redeploying app

#### Cons

* Person tests will require a `Greeting` object to be created
* Displaying form options require database query

### Module

The concept of a greeting and its associated validations is really a discreet concept, and it would be nice to isolate its implementation from our `Person` class.

This list is not expected to change much if ever we like to avoid querying the database to get the list of greetings or the display the value for a `Person` instance.

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

This solution is admittedly more code, but we also have included more features. In this version we have implemented support for a `greeting_other` database column which could store custom greetings entered by the user.

We have also added the `FormOptions` constant which can be used in a form builder to build a `<select>` with the valid values for a greeting. Most importantly, we make zero database calls to get these values which means faster tests with less setup and less load in our application. Speaking of testing, the tests for this "Module" pattern is a great place to use [Rspec shared_examples](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples).

Because we are storing our reference to a greeting in a `greeting_id` on the `Person` table, it would be simple refactor to the "Database Table" pattern in the future.

#### Pros

* No database queries
* Easier test setup
* Supports form builders
* Easy to convert to table
* Supports `Other` option

#### Cons

* Changes require redeploying application
* More lines of code

### Enums

The module pattern I have shown above is similar to the [enum](http://en.wikipedia.org/wiki/Enumerated_type) support that many programming languages have built into the language. While Ruby does not have native support enums, a new [feature](http://edgeguides.rubyonrails.org/4_1_release_notes.html#active-record-enums) in Rails 4.1 gives us an implement of enums to use with ActiveRecord.

```ruby
class Person < ActiveRecord::Base
  enum greeting: { hi: 1, hello: 2, dear: 3 }

  validates :greeting, presence: true

  def greeting_value
    greeting.capitalize
  end
end
```

Using the new ActiveRecord enums has the advantage of creating dynamic methods like `hi!` and `hi?` to set the value of `greeting` and check that the value matches a specific enum value.

To use these enums in a form helper we can do a map of the hash we get from the `Person.greetings` method.

```ruby
Person.greetings.map do |greeting, id|
  [greeting.capitalize, id]
end
```

This solution ends up being the smallest amount of code. Although we do have the inconvience of our form helper not being defined in just one place, but that could be addressed with custom class method.

#### Pros

* Simple implementation
* Dynamic method creation
* No database queries

#### Cons

* Changes require redeploying application
* No form builder support

### Conclusion

As we have compared these patterns for static lists, we can see that there are contexts in which each solution will shine.

A "Database Table" is easy to create and allows live changes, the "Module" pattern is flexible with good support for introspection and extending with blocks, and ActiveRecord enums are a simple solution with good support for representing states of an object.

With that said, I have found that the "Module" pattern is a good place to start, however, I'll be curious to see how [ActiveRecord enums](http://edgeguides.rubyonrails.org/4_1_release_notes.html#active-record-enums) evolves over time and look forward to trying it on a project.

If you would like to compare these implementations in more depth I have put together a [sample app](https://github.com/calebwoods/static_lists_post) which includes tests for each solution.

---

**Edit** in response to this blog post, [@ravinggenius](https://twitter.com/ravinggenius) put together a [gist](https://gist.github.com/ravinggenius/9983704) of how you could build an abstraction to simplify "Module" pattern and reduce boiler plate code. This could probably be taken a bit further to also create helper methods like ActiveRecord enums provides.
