require Main.root('app/init/sequel.rb')
require 'fileutils'

FileUtils.mkdir_p 'db'  unless Main.production?

if Main.test?
  Main.database_url = "sqlite://db/test.db"
elsif Main.development?
  Main.database_url = ENV['DATABASE_URL'] || "sqlite://db/development.db"
end
