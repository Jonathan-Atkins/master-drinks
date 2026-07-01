class ChangeAmountToDecimalInRecipeIngredients < ActiveRecord::Migration[8.1]
  def change
    change_column :recipe_ingredients,
                  :amount,
                  :decimal,
                  precision: 8,
                  scale: 2,
                  using: "amount::numeric"
  end
end