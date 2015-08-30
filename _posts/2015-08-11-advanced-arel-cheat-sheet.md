---
layout: post
title: "Advanced Arel Cheat Sheet"
date: "2015-08-11"
tags:
  - rails
  - reference
---

After seeing [@camertron](https://twitter.com/camertron)'s talk on Advance Arel from Rails Conf 2014 ([slides](http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough)) I've wanted a simple reference for the most common Arel comparators that I forget to use instead of string interpolation.

This post was motivated by a recent bug I found in one of my applications where using string interpolation with joined relations caused an ambiguous column SQL error. While this post is intended to serve as a personal reference, it may be useful to others as well.

Also check out [scuttle.io](http://www.scuttle.io/) as a further resource to translate SQL to Arel.

**Note** Arel is considered an internal API for ActiveRecord and can change between major Rails versions. 
### Setup

My examples assume a Rails 4.2 application and a single `Post` model with 2 attributes `title` and `published_date`, [gist](https://gist.github.com/calebwoods/af61c6af057067f55a27).

Note that pulling in the [arel-helpers](https://github.com/camertron/arel-helpers) gem can eliminate the need to keep calling `arel_table` all over the place and adds some potentially useful join helpers.

### Equality

Greater than

```ruby
Post.where(
  Post.arel_table[:published_date].gt(Date.new(2015, 8, 11))
)

# instead of

Post.where('published_date > ?', Date.new(2015, 8, 11))

```

Less than

```ruby
Post.where(
  Post.arel_table[:published_date].lt(Date.new(2015, 8, 11))
)

# instead of

Post.where('published_date < ?', Date.new(2015, 8, 11))
```

Greater than or equal

```ruby
Post.where(
  Post.arel_table[:published_date].gteq(Date.new(2015, 8, 11))
)

# instead of

Post.where('published_date >= ?', Date.new(2015, 8, 11))
```

Less than or equal

```ruby
Post.where(
  Post.arel_table[:published_date].lteq(Date.new(2015, 8, 11))
)

# instead of

Post.where('published_date <= ?', Date.new(2015, 8, 11))
```

Not equal

```ruby
Post.where(Post.arel_table[:title].not_eq('Sample Post'))

# instead of

Post.where('title != ?', 'Sample Post')
```

### Matching / (I)LIKE

```ruby
Post.where(Post.arel_table[:title].matches('%sample%'))

# instead of

Post.where('title ILIKE ?', '%sample%')
```

### Ordering

```ruby
Post.order(Post.arel_table[:publish_date].desc)

# instead of

Post.order('publish_date DESC')
```

If you are looking for even more flexibility and control than what ActiveRecord provides, I would highly recommend the [sequel](https://github.com/jeremyevans/sequel) gem.

Have other tricks you use with ActiveRecord? Tweet at me [@calebwoods](https://twitter.com/calebwoods).
