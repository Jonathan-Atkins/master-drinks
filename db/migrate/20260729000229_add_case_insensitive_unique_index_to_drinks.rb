class AddCaseInsensitiveUniqueIndexToDrinks < ActiveRecord::Migration[8.1]
  def change
    add_index :drinks,
              "LOWER(name)",
              unique: true,
              name: "index_drinks_on_lower_name"
  end
end
