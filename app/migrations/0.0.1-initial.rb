class Main
  migration "v0.0.2 documents" do
    database.create_table :documents do
      primary_key :id
      String :data, text: true
    end
  end
end
