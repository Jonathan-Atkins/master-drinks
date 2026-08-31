class MakeIngredientUserOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :ingredients, :user_id, true
  end
end
