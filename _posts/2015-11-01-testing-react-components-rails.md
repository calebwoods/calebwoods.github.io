---
layout: post
title: "Testing React Components in Rails"
date: "2015-11-01"
tags:
  - rails
  - testing
  - react
---

As mentioned in a [previous post](/2015/10/19/choosing-frontend-form-data-heavy-applications/), part of my current learning and experimentation is finding ways to mix a "traditional" Rails application with Javascript components.

Recently, I've been further exploring [React](https://facebook.github.io/react/), which I really like, but I couldn't find a simple way to unit test components in a Rails app using the [Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html). The benefit I'm looking for is being able to do a bulk of the frontend with server side rendered views as they are easy to build quickly and add React components for parts of the interface that need it.

Most React testing examples assume a [CommonJS](http://requirejs.org/docs/commonjs.html) way of structuring and requiring Javascript files.  Strangely,  or maybe to increase adoption, the  [react-rails](https://github.com/reactjs/react-rails) gem integrates with the Asset Pipeline and I wanted to find a testing solution to match.

### Component

As an example I'll implement the CheckboxWithLabel component used in the [Jest](http://facebook.github.io/jest/) [React tutorial](https://facebook.github.io/jest/docs/tutorial-react.html).

```js
// app/assets/javascripts/components/checkbox_with_label.js.jsx
var CheckboxWithLabel = React.createClass({

  getInitialState: function () {
    return { isChecked: false }
  },

  onChange: function () {
    this.setState({isChecked: !this.state.isChecked});
  },

  render: function () {
    var label = this.state.isChecked ? this.props.labelOn : this.props.labelOff;

    return (
      <label>
        <input
          type="checkbox"
          checked={this.state.isChecked}
          onChange={this.onChange}
        />
        {label}
      </label>
    );
  }

});
```

### Test Setup

Rather than using [Jest](http://facebook.github.io/jest/) for our tests I'll use [Jasmine](http://jasmine.github.io/), which Jest is built on but is easier to integrate with Rails using the [jasmine-rails](https://github.com/searls/jasmine-rails) gem.

After adding `jasmine-rails` to the Gemfile and running the installer, `rails generate jasmine_rails:install`, we just need to make a couple changes.

First we need to configure `react-rails` to include the `TestUtils` addon in `config/application.rb`.

```ruby
# config/appliction.rb
module ReactTesting
  class Application < Rails::Application
    config.react.addons = true
  end
end
```

To enable using the JSX preprocessor in our test we simply need to modify the `spec_files` matcher in `spec/javascripts/support/jasmine.yml`.

```yaml
spec_files:
  - "**/*[Ss]pec.{js.jsx,js,jsx}"
```

If you want to support coffee script in your tests as well, you can use something like:

```yaml
spec_files:
  - "**/*[Ss]pec.{js.jsx.coffee,js.jsx,js.coffee,js,jsx,coffee}"
```

Also, to force the use of [PhantomJS](http://phantomjs.org/) 2.x which is already installed on my laptop we need to add:

```yaml
use_phantom_gem: false
```

You'll also want to make sure your CI server is using PhantomJS 2.x.  For [Travis CI](https://travis-ci.com/) just add  the following to your `.travis.yml` file.

```yaml
before_install:
  - wget https://s3.amazonaws.com/travis-phantomjs/phantomjs-2.0.0-ubuntu-12.04.tar.bz2
  - tar -xjf phantomjs-2.0.0-ubuntu-12.04.tar.bz2
  - export PATH=$PWD:$PATH
```

Now on to writing our test.

### Test

Our test will have two assertions. First to check the initial test is correct and a second after simulating a change.

```js
// spec/javascripts/components/checkbox_with_label_spec.js.jsx
var TestUtils = React.addons.TestUtils

describe('CheckboxWithLabel', function () {

  it('changes the text after click', function () {
    // Render a checkbox with label in the document
    var checkbox = TestUtils.renderIntoDocument(
      <CheckboxWithLabel labelOn="On" labelOff="Off" />
    );

    var checkboxNode = ReactDOM.findDOMNode(checkbox);

    // Verify that it's Off by default
    expect(checkboxNode.textContent).toEqual('Off');

    // Simulate a click and verify that it is now On
    TestUtils.Simulate.change(
      TestUtils.findRenderedDOMComponentWithTag(
        checkbox,
        'input'
      )
    );
    expect(checkboxNode.textContent).toEqual('On');
  });

});
```

This matches the sample test is from the [Jest tutorial](https://facebook.github.io/jest/docs/tutorial-react.html).  Although it should probably be noted we will not have access to Jest's [Automatic Mocking](https://facebook.github.io/jest/docs/mock-functions.html#content) feature as we are using Jasmine instead.

If we want to avoid declaring the `TestUtils` variable in each file we can extract it as a helper.

```js
// spec/javascripts/helpers/react_helper.js
window.TestUtils = React.addons.TestUtils
```

### Running Tests

Now to run tests we have two options: Rake task and browser.

#### Rake task

The `jasmine-rails` gem includes a Rake task `spec:javascripts`.

```
$ bundle exec rake spec:javascripts
Starting...

Finished
-----------------
1 spec, 0 failures in 0.023s.

ConsoleReporter finished
```

You can also configure this task to run as part of the default rake task.

```ruby
# Rakefile
task :default => [ 'spec:javascripts' ]
```

#### Browser

Another benefit with the `jasmine-rails` gem is that it configures and mounts the Jasmine runner at `/specs` in your Rails app.

![Jasmine Runner in Browser](/images/jasmine_in_browser.png)

This means using can easily stick a `debugger` statement in your test and use the Chrome web inspector to step through your tests.

### Conclusion

Let's evaluate what we have.

Pros:

* Simple setup with existing tools
  * [Don't have to install npm packages](http://reactjsnews.com/setting-up-rails-for-react-and-jest/)
  * Still using the Assets Pipeline
* Easy to run tests via Rake task (for CI) and browser (for debugging)

Cons:

* Not using Jest
  * [Automatic Mocking](https://facebook.github.io/jest/docs/automatic-mocking.html#content) would seem to be the biggest loss

This solution does assume you want to keep using the Asset Pipeline, but I'm guessing for most Rails apps that's the easiest way to get started with React and it follows the style of the `react-rails` gem.

If you'd like to see the full running code, I've created a minimal sample application at [https://github.com/calebwoods/react_testing](https://github.com/calebwoods/react_testing).
