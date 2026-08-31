class ScopeDrinkNameUniquenessToUser < ActiveRecord::Migration[8.1]
  def change
    remove_index :drinks,
                 name: "index_drinks_on_lower_name"

    add_index :drinks,
              "user_id, LOWER(name)",
              unique: true,
              name: "index_drinks_on_user_id_and_lower_name"
  end
end
