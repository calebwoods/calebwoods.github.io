---
layout: post
title: "Testing Rails APIs with JSON Schema"
date: "2017-03-08"
tags:
  - testing
  - api
  - rails
  - json
---

Recently got a chance to experiment with using JSON Schema to test-drive new APIs. My motivation behind this was to find a better way to document and more thoroughly test an API with low overhead.

In the past, I've used tools like [Swagger](http://swagger.io/) and [Grape Entity](https://github.com/ruby-grape/grape-entity) to provide auto-generated API docs, but it wasn't integrated into tests and require duplication of similar information.

Another large project of mine used a custom documentation toolchain of rake, markdown, and curl to execute and record requests to a development server embedded in markdown documentation. This worked well, but had to be manually kept up to date as changes to the API couldn't easily be detected.

Ultimately I want a way to get decent API documentation (entity structure and endpoints) extracted from my tests.  At one point I even experimented with building an RSpec formatter to generate documentation.

So when I saw a [blog post](https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher) about using [JSON Schema](http://json-schema.org/) to test APIs I wanted to explore it further to see what was possible.

## Creating the schema

[JSON Schema](http://json-schema.org/), at a basic level, gives you a way to describe properties and types of a JSON structure. It also has support for composing schemas which I found useful for API testing.

For our RSpec setup, we will put all our schemas under `spec/support/schemas`.  In this folder I created a special `definitions.json` file which describes all the entities in the API. Similar to how you might have `spec/support/factories.rb` define all your test factories.

```json
// definitions.json

{
  "definitions": {
    "author" : {
      "type" : "object",
      "required" : [
        "id",
        "name",
        "active"
      ],
      "properties" : {
        "id" : { "type" : "integer" },
        "name" : { "type" : "string" },
        "active" : { "type" : "boolean" }
      }
    },
    "comment" : {
      "type" : "object",
      "required" : [
        "id",
        "content",
        "author"
      ],
      "properties" : {
        "id" : { "type" : "integer" },
        "content" : { "type" : "string" },
        "author" : { "$ref" : "#/definitions/author" }
      }
    },
    "post" : {
      "type" : "object",
      "required" : [
        "id",
        "title",
        "content",
        "author"
      ],
      "properties" : {
        "id" : { "type" : "integer" },
        "title" : { "type" : "string" },
        "content" : { "type" : "string" },
        "author" : { "$ref" : "#/definitions/author" },
        "comments": {
          "type": "array",
          "items": { "$ref": "#/definitions/comment" }
        }
      }
    }
  }
}
```

Then I also created a series of API endpoint specific files such as `posts.json` that describe how that specific API endpoint uses the schema definitions.

```json
// posts.json
{
  "type": "object",
  "required": ["posts"],
  "properties": {
    "posts": {
      "type": "array",
      "items": { "$ref": "definitions.json#/definitions/post" }
    }
  }
}
```


### Using in Schema in Tests

Following the original [blog post](https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher) I created a RSpec matcher to make matching schemas in tests easier.

```ruby
# spec/support/api_schema_matcher.rb

RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    schema_directory = "#{Dir.pwd}/spec/support/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(
      schema_path,
      response.body,
      strict: true
    )
  end
end
```

This matcher will compare our API `response` with the `schema` specified and determine if they match using a class from the [json-schema](https://github.com/ruby-json-schema/json-schema) gem.

Then in our tests, we can call our custom matcher to ensure request matches the schema.  In addition I usually "spot check" a couple of the values to ensure the data is correct and not just in the right format.

The schema will be used to validate the types of the rest of the properties and that all require properties are included. Our test will also fail if extra properties that we didn't define are included in the response.

```ruby
# spec/api/posts.rb

require 'rails_helper'

RSpec.describe PostsController, type: :request do
  include_context 'API'

  describe 'GET index' do
    context 'get all published posts' do
      let!(:author) do
        Author.create!(name: 'Test Author')
      end
      let!(:draft_post) do
        Post.create!(
          author: author,
          title: 'Draft',
          content: 'Great stuff'
        )
      end
      let!(:published_post) do
        Post.create!(
          author: author,
          title: 'Published',
          published_at: 1.day.ago,
          content: 'Better stuff'
        )
      end
      let!(:comment) do
        Comment.create!(
          author: author,
          post: published_post,
          content: 'Well done'
        )
      end

      before { api_get 'posts' }

      specify do
        expect(json_body['posts'].count).to eq 1
        expect(response).to match_response_schema('posts')
        expect(
          json_body['posts'].first['author']['name']
        ).to eq author.name
      end
    end
  end
end
```

If our server's response didn't match the expected schema, we'd see a well-formed error like this:

```
JSON::Schema::ValidationError:
  The property '#/posts/0' did not contain
  a required property of 'author'
```

### Next Steps

This is a decent example of testing a read-only API, but would like to explore how usage might change when testing create/update responses.  Things would also be a bit different if using [JSON API](http://jsonapi.org/) format for your API as relationship are side loaded rather than inlined.

Additionally, I think there is an interesting possibility to create a "documentation viewer" that could parse the schema files and build simple API documentation.  Hope to explore that in a future post.

A full example app for this post is available [on my Github account](https://github.com/calebwoods/json-schema-testing).
