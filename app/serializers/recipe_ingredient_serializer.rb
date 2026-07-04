class RecipeIngredientSerializer
  def self.format(recipe_ingredient)
    {
      name: recipe_ingredient.ingredient.name,
      amount: recipe_ingredient.amount.to_f,
      measurement_unit: recipe_ingredient.measurement_unit
    }
  end
end
