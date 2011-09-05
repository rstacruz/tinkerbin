ENV['RACK_ENV'] ||= 'development'

# Bundler
require "bundler"
Bundler.require :default, ENV['RACK_ENV'].to_sym

# Loadables
# $:.unshift *Dir["./vendor/*/lib"]
$:.unshift *Dir["./lib"]

class Main < Sinatra::Base
  set      :root, lambda { |*args| File.join(File.dirname(__FILE__), *args) }
  set      :run,  lambda { __FILE__ == $0 and not running? }
  set      :views, root('app', 'views')

  enable   :raise_errors, :sessions, :logging
  enable   :show_exceptions  if development?

  use      Rack::Session::Cookie
end

# Load files
(Dir['./config/defaults/*.rb'].sort +
 Dir['./config/*.rb'].sort +
 Dir['./app/init/*.rb'].sort +
 Dir['./app/**/*.rb'].sort
).uniq.each { |rb| require rb }

Main.set :port, ENV['PORT'].to_i  if ENV['PORT']
Main.run!  if Main.run?
