---
layout: post
title: "Intermittent Offline System Tests"
date: "2019-02-02"
tags:
  - testing
  - offline
  - rails
---

As a new feature for [Ninja Master](https://ninjamasterapp.com/), my team wanted to better support the intermittent connections users may experience while running competitions. The typical usage is on a phone (over WiFi or LTE) in a large metal building which will likely have lots of interference.

To solve this we implemented some special error handling for intermittent connections to ensure users could keep timing their competition and only require a solid connection for the final submission of run data to the server.

### Manual Testing

![Manual Offline Testing](/images/offline/manual_offline.gif)

Using the Chrome DevTools it is pretty easy to [simulate offline behavior](https://developers.google.com/web/ilt/pwa/tools-for-pwa-developers#simulate_offline_behavior) with a checkbox. This worked great for spiking the functionality, but I still wanted to find a way to add coverage for this new behavior to our [RSpec System tests](https://relishapp.com/rspec/rspec-rails/docs/system-specs/system-spec).

### Programatic Solution

A common solution I've seen mentioned when searching on this topic is to add a Rack Middleware around your application that will return error codes when a global variable is set by your test runner. This could have worked, but didn't seem as clean, especially for quickly toggle the offline mode on and off. Given that we are already using Chromedriver and Selenium for our System tests I started looking for a simple way to hook into the network features in Chrome DevTools.

After doing some spelunking in Pry, I discovered that through a [Selenium Extension](https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/DriverExtensions/HasNetworkConditions.html), Chromedriver exposes a couple methods for reading and manipulating the Network Conditions: `network_conditions` and `network_conditions=`. Note that the documentation mentions that this is a Private API.

### Toggling Offline

In the System tests, I simply access Selenium through Capybara to set offline mode with:

```ruby
page.driver.browser.network_conditions = {
  latency: 0,
  throughput: 0,
  offline: true
}
```

Then to go back online simply update the `offline` and `throughput` parameters:

```ruby
page.driver.browser.network_conditions = {
  latency: 0,
  throughput: 1_000_000,
  offline: false
}
```


To make things clearer I also wrapped these commands into `go_offline` and `go_online` helper methods.

![Automated Offline Testing](/images/offline/automated_offline.gif)

I'm really happy with how this approach turned out. It provides a simple way to ensure that offline or intermittent connection behavior can be driven by tests and doesn't require messing with global variables or Rack middleware.
