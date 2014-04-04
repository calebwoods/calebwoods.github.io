---
layout: post
title:  "Static Lists: Database Table, Module, or Enums"
date:   2014-04-03 20:00:00
---

In my expiriene of building web applications there has been the need for a pattern to solve the problem of static lists. By static lists I mean things like: US States, name prefixes, roles, etc.

For comparison we'll look at three solutions to solve this problem for a Rails app. Our example will a Person object with a list of greetings options: Hi, Hello, Dear.

```ruby
class Person < ActiveRecord::Base
end
```

### Database Table

In a Ruby on Rails application adding new database table is an easy thing and make adding new greetings to list very straight forward. If we implemented a Greeting ActiveRecord object we might end up with some code like this.

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
* Add more greetings without redeploying app

#### Cons

* Person tests will require Greeting object to be created
* Displaying form options requires database query

### Module

The concept of a greeting and it's associated validations is really a discreet concept and it would be nice to isolate it's implementation from our `Person` class.

This list is not expected to change much if ever we like to not have to query the database to get the list of greetings or the display the value for a `Person` instance.

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

This solution is admittedly more code, but we've also got some more features. In this version we've implement support for an `greeting_other` database column which could store custom greetings entered by user.

We've also added the `FormOptions` constant which can be used in a form builder to build select with the valid values for a greeting. Most importantly we make zero database calls to get these values which means faster tests with less setup and less load in our application. Speaking of testing, this "Module" I've found is a great place to [Rspec shared_examples](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples).

Because we are storing our reference to a greeting in a `greeting_id` on the Person table it would straight forward to move the "Database Table" pattern in the future.

#### Pros

* No database queries
* Easier test setup
* Supports form builders
* Used with any ORM
* Easy to convert to table
* Support `Other` option

#### Cons

* Changes require redeploying application
* More lines of code

### Enums

The module pattern I've shown above is similar to the [enum](http://en.wikipedia.org/wiki/Enumerated_type) support that many programming languages have built in to the language. While Ruby doesn't have native support enums a new [feature](http://edgeguides.rubyonrails.org/4_1_release_notes.html#active-record-enums) in Rails 4.1 gives us an implement of enums to use with ActiveRecord.

```ruby
class Person < ActiveRecord::Base
  enum greeting: { hi: 1, hello: 2, dear: 3 }

  validates :greeting, presence: true

  def greeting_value
    greeting.capitalize
  end
end
```

Using the new ActiveRecord enums has the advantage of creating dynamic methods like `hi!` and `hi?` to set the value of `greeting` and check the value matches a specific enum value.

To use these enums in a form helper we can do a map of the hash we get from the `Person.greetings` method.

```ruby
Person.greetings.map do |greeting, id|
  [greeting.capitalize, id]
end
```

This solution ends up being the smallest amount of code although we've have the convience of our form helper being defined in just one place, but that could be addressed with custom class methods.

#### Pros

* Simple implementation
* Dynamic method creation
* No database queries

#### Cons

* Change require redeploying application
* No form builder support

### Conclusion

As we've compared these patterns for solving our static lists we can see that there are contexts where each solution will shine.

A "Database Table" is easy create and allows live changes, the "Module" pattern is flexible with good support for introspection and exstending with blocks, and ActiveRecord enums is a simple solution with good support representing states of an object.

With that said I've found that the "Module" pattern is a good place to start when solving this problem, however, I'll be curious to see how [ActiveRecord enums](http://edgeguides.rubyonrails.org/4_1_release_notes.html#active-record-enums) evolves over time and look forward to trying it on a project.

If you'd like to compare these implementations in more depth I've put together a [sample app](https://github.com/calebwoods/static_lists_post) which includes tests for each solution.
