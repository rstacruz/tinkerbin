require Main.root('app/init/sequel.rb')
require 'fileutils'

if Main.test?
  FileUtils.mkdir_p 'db'
  Main.database_url = "sqlite://db/test.db"
else
  FileUtils.mkdir_p 'db'
  Main.database_url = ENV['DATABASE_URL'] || "sqlite://db/development.db"
end
