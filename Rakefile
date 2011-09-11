require './lib/log_helpers'
extend LogHelpers

Dir['./lib/tasks/**/*.rake'].each { |f| load f }
task :default => :help

namespace :doc do
  task :build do
    system "reacco -a --api lib"
  end
end
