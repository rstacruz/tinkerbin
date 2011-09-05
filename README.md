# My project
#### Description goes here

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
