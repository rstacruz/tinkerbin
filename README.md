# Tinkerbin
#### [tinkerbin.heroku.com}(tinkerbin.heroku.com)

Requirements
------------

- **Ruby 1.9.2**
   - RVM: `rvm install 1.9.2`
   - Ubuntu: `sudo apt-get install ruby19`

- **[RVM](http://rvm.beginrescueend.com)** -- optional

Setup
-----

Create an RVM gemset (optional):

    $ rvm --rvmrc --create @myproject

Install gems:

    $ bundle install

Start it like any Rack app:

    $ rackup       # or `thin start`, `unicorn`, etc

Run tests:

    $ rake test

Todo
----

 - Autoupdating for Less
 - Save!
 - Open

Done
----

 - Local updating
 - Notification that auto-updating is on/off
 - Focus styles
