class UnitTest
  setup do
    Main.set :migrations_log, lambda { StringIO.new }
    Main.db_flush!
    Main.run_migrations!
  end
end
