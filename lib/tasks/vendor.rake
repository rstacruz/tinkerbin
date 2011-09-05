def get(url, options={})
  require 'fileutils'
  target = options[:as].squeeze('/')

  puts "* #{target}..."
  FileUtils.mkdir_p File.dirname(target)
  system "wget \"#{url}\" -O \"#{target}\""
end

desc "Vendor JS libraries"
task :vendor, :library do |_, args|
  require './init'

  lib = args[:library]
  lib = lib.to_sym  if lib

  packages = Main.js_packages
  prefix   = './app'

  if lib
    options = packages[lib]
    unless options
      puts "Don't know the library #{lib}."
      exit
    end

    get "http:#{options[:remote]}", as: "#{prefix}/#{options[:fallback]}"

  else
    packages.each { |name, options|
      get "http:#{options[:remote]}", as: "#{prefix}/#{options[:fallback]}"
    }
  end

  puts "Done."
end
