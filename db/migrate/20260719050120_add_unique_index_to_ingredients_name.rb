class AddUniqueIndexToIngredientsName < ActiveRecord::Migration[8.1]
  def change
    add_index :ingredients, "LOWER(name)", unique: true
  end
end
