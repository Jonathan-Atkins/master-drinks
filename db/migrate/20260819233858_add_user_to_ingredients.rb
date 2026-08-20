class AddUserToIngredients < ActiveRecord::Migration[8.1]
  def up
    add_reference :ingredients, :user, null: true, foreign_key: true


    Ingredient.where(user_id: nil).update_all(user_id: User.first.id)

    change_column_null :ingredients, :user_id, false
  end

  def down
    remove_reference :ingredients, :user, foreign_key: true
  end
end