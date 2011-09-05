require_relative './sequel'

class Main
  migration "v0.1.0 create tables" do
    database.create_table :categories do
      String :id, primary_key: true
      String :name

      String :keywords, text: true
    end
  end
  
  # Load moar
  Dir[Main.root('app/migrations/*.rb')].sort.each { |f| load f }
end

