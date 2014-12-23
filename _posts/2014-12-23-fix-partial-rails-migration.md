---
layout: post
title:  "Fix Partial Rails Migration"
date:   2014-12-23 10:15:00
---

Using Rails migrations with databases that do not support [DDL Transactions](http://www.sql-workbench.net/dbms_comparison.html) like Oracle and MySQL can be a pain.  Recently, on project where we are using Postgres for development and Oracle in production, I ran into a case where I needed to run a conditional migration to fix schema for production.

### The Problem

While using ActiveRecord does help to make switching databases easier there are some database specific constraints that it doesn't completely solve.

For example, Oracle has a limit on the number of characters used for an index name, 30, and limits you to one index per column.

Because we have to manually specify index names in migrations to get them under 30 characters it's possible to make mistakes like the following, specifying two indexes for the same column.

```ruby
class AddPostIndexes < ActiveRecord::Migration
  def change
    add_index :posts, :author_id, { name: 'post_author_idx' }
    add_index :posts, :author_id, { name: 'post_editor_idx' }
  end
end
```

In Postgres this is fine as you can have multiple indexes for the same column.  But in Oracle the migration will fail when it tries  to add the second index.

### Solution

To fix this problem from happening in the future we can edit the migration to be correct.

```ruby
class AddPostIndexes < ActiveRecord::Migration
  def change
    add_index :posts, :author_id, { name: 'post_author_idx' }
    add_index :posts, :editor_id, { name: 'post_editor_idx' }
  end
end
```

However, that doesn't solve the issue of the local development databases that are already incorrect.  To solve this we'll need to use a conditional migration to remove the old index.

### Conditional Migration

Thankfully ActiveRecord gives us a way to query the [indexes](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/PostgreSQL/SchemaStatements.html#method-i-indexes) of each table and we can use this information to write a migration that will remove the incorrect `post_editor_idx` if it exists and allow us to add the right index.

```ruby
class FixPostIndexes < ActiveRecord::Migration
  def up
    indexes = ActiveRecord::Base.connection.indexes(:posts)
    if indexes.map { |i| i.name }.include?('post_editor_idx')
      remove_index :posts, { name: 'post_editor_idx' }
    end
    add_index :posts, :editor_id, { name: 'post_editor_idx' }
  end

  def down
    remove_index :posts, { name: 'post_editor_idx' }
  end
end
```

With this solution we can now have other developers run the new migration and their local development database will be up to date.  If we had just changed the already run migration `AddPostIndexes` then other developers would have needed to drop and recreate their databases from scratch.

ActiveRecord also gives a method to query the table [columns](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/PostgreSQL/SchemaStatements.html#method-i-columns) in the same way as indexes.
