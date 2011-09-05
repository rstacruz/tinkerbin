require Main.root('app/init/sequel.rb')
require 'fileutils'

FileUtils.mkdir_p 'db'

if Main.test?
  Main.database_url = "sqlite://db/test.db"
else
  Main.database_url = ENV['DATABASE_URL'] || "sqlite://db/development.db"
end
