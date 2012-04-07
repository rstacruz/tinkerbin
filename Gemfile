source "http://rubygems.org"

# Sinatra microframework
gem "sinatra", "~> 1.3.0", require: "sinatra/base"

# JS Compression
gem "jsmin", "~> 1.0.1"

# Template engines
gem "haml", "~> 3.1.1"
gem "sass", "~> 3.1.1"
gem "less"

# Sinatra extensions
gem "sinatra-contrib", require: "sinatra/content_for"
gem "sinatra-support", "~> 1.2.0", require: "sinatra/support"
gem "sinatra-assetpack", git: "git://github.com/rstacruz/sinatra-assetpack.git", require: "sinatra/assetpack"
gem "sinatra-backbone", git: "git://github.com/rstacruz/sinatra-backbone.git", require: false

# CSS extensions
gem "compass", "~> 0.11.5"

# Automatic development-time reloading of code
gem "pistol", "~> 0.0.2"

# Rtopia link helper
gem "rtopia", "~> 0.2.3"

# # Sequel ORM
gem "sequel"
gem "sinatra-sequel", require: "sinatra/sequel"
gem "sqlite3", group: [:test, :development]
# gem "mysql",   group: :production

# # CoffeeScript support (with Heroku support)
gem "coffee-script", require: "coffee_script"
gem "therubyracer-heroku", "0.8.1.pre3", require: false  if ENV['HEROKU']

group :test do
  # Contexts for test/unit
  gem "contest"

  # Mocking and stubbing
  gem "mocha", "~> 0.9.12"

  # Acceptance tests via browser simulation
  gem "capybara", "~> 1.0.1"

  # More Capybara drivers
  # gem "capybara-envjs", require: "capybara/envjs"
  # gem "capybara-webkit"

  # # RSpec-like syntax (two.should == 2)
  # gem "renvy", "~> 0.2.0"

  # # Generates fake data (names, addresses, etc)
  # gem "ffaker", "~> 1.4.0"
end
