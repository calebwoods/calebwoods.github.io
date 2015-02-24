---
layout: post
title: "Poltergeist with Rails and Angular"
date: "2015-02-23"
---

This past week I worked on converting a Rails and Angular application that was using Selenium as the driver for [Spinach](https://github.com/codegram/spinach)/[Capybara](https://github.com/jnicklas/capybara) tests over to using [Poltergeist](https://github.com/teampoltergeist/poltergeist).

The change was motivated by the fact that our Spinach tests using Selenium where taking an average of 4 minutes to run.  That's not terrible, but could definitely be improved.  Also, I wanted to look into running tests in parallel which would be easier with a headless driver.

**Spoiler alert**: 2x speed improvement ahead.

### Getting PhantomJS Running

When I first switched our tests over to using Poltergeist I noticed that even though links where being clicked ui-router was not transitioning to the new state.

After some digging I realized the issue was that PhantomJS does not support [Function.prototype.bind](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind) in 1.9.x versions and our app had code in the [resolve](https://github.com/angular-ui/ui-router/wiki#resolve) section of our states was using `bind`.  When calling `bind` failed the state transition would be halted.

The solution is to add a polyfill such as [this bower package](https://github.com/kdimatteo/bind-polyfill) which can be installed using [Rails Assets](https://rails-assets.org/).

```ruby
# Gemfile
source 'https://rails-assets.org'
gem 'rails-assets-bind-polyfill'

# application.js
//= require bind-polyfill
```

### Throwing Errors

By default Poltergeist does not re-raise errors, however, having this turned on is usually helpful in finding errors.  Angular makes this a challenge though: instead of throwing errors it catches them using the `$exceptionHandler` service and logs them.  If we want to be able to re-raise errors we will need to load an extension for Poltergeist.

```ruby
# features/support/env.rb
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    extensions: [ 'features/support/angular_errors.js' ],
    js_errors:   true
  )
end
```

In our extension we can redefine the `error` function on the `$log` service to instead throw an exception.  Original script taken from the [Localytics blog](http://eng.localytics.com/a-year-on-angular-on-rails/).

I also added void implementations for `$log.info` and `$log.debug` to clean up test output as our app logs every state transition with debugging information.

```js
// features/support/angular_errors.js
window.onload = function() {
  var $injector = angular.element(document).injector();
  var $log = $injector.get('$log');

  // Raise Angular errors
  $log.error = function(error) { throw(error); };

  // Suppress Angular Logging
  $log.info = function () {};
  $log.debug = function () {};
};
```

### Debugging

One thing that's always hard with a headless browser is to see what's going on when the test is interacting with the page.  For basic debugging, I've found that taking a screenshot using the `save_screenshot` method while in a [Pry](http://pryrepl.org/) session of stepping through your tests works well.

```ruby
save_screenshot('/Users/caleb/Desktop/debug.png', full: true)
```

For debugging tests that don't have driver specific issues I still like to use Selenium so that you can click around the page.  So I created a hook to switch the driver any time the `@selenium` tag is added to a scenario.

```ruby
Spinach.hooks.on_tag('selenium') do
  Capybara.current_driver = :selenium
end
```

### 2x Speed Improvement

After fixing a couple of tests that used features of Capybara specific to Selenium and some issues with [mouse events](https://github.com/teampoltergeist/poltergeist#mouseeventfailed-errors), I was able to run the entire test suite with Poltergeist.

With these changes in place running Spinach tests, which took 4 minutes using Selenium, now took just 2 minutes.  Well worth the effort.

**Edit 2015-02-24**: Today after upgrading [PhantomJS to version 2.0.0](http://phantomjs.org/release-2.0.html) I'm seeing even more remarkable speed improvements.  The same Spinach tests now run in about 75 seconds.  Overall a 3.2x improvement from using Selenium.
