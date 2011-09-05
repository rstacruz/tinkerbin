require './lib/log_helpers'
extend LogHelpers

Dir['./lib/tasks/**/*.rake'].each { |f| load f }
task :default => :help

# You may want to remove this crap, these have no use in production.

desc "Starts the server [Development]"
task(:start) {
  system "ruby init.rb"
}

desc "Opens a console session [Development]"
task(:irb) {
  irb = ENV['IRB_PATH'] || 'irb'
  system "#{irb} -r./init.rb"
}

namespace :example do
  desc "Lists available recipes [Examples]"
  task :list do
    puts "Available recipes:"
    list = Dir['./**/*.example'].map { |f| File.basename(f).match(/([^\.]+)(.[^\.]+){2}$/) && $1 }.uniq
    list.each { |item| puts " * rake recipes:load[#{item}]" }
  end

  desc "Clears all example files [Examples]"
  task :clear do
    Dir['./**/*.example'].each { |f| FileUtils.rm f }
  end

  desc "Loads a given recipe [Examples]"
  task :load, :recipe do |t, args|
    recipe = args[:recipe]
    Dir["./**/*#{recipe}.*.example"].each { |from|
      to = from.gsub(/(\.#{recipe})|(\.example)/, '')
      puts "%40s -> %s" % [ from, to ]
      FileUtils.mv from, to  unless ENV['SIMULATE']
    }
    puts "Okay, now add the appropriate gems to your gemfile."
  end
end

task :examples => :'example:list'
