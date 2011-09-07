class Main
  migration "v0.0.1 create tables" do
    database.create_table :categories do
      String :id, primary_key: true
      String :name

      String :keywords, text: true
    end
  end
end
