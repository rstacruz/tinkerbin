namespace :db do
  desc "Create/alter tables"
  task(:migrate) {
    require './init'
    Main.run_migrations!
  }
  
  desc "Drop tables"
  task(:drop) {
    require './init'
    Main.db_flush! { |table| puts "* Dropping #{table}..." }
  }
end
