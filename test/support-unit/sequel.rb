class UnitTest
  setup do
    Main.set :migrations_log, lambda { StringIO.new }
    Main.db_flush!
    Main.db_auto_migrate!
  end
end
