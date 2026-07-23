class DrinkSerializer
  def self.format(recipe)
    {
      id: recipe.id,
      name: recipe.name,
      instructions: recipe.instructions,
      drink: {
        id: recipe.drink.id,
        username: recipe.drink.user.username,
        name: recipe.drink.name,
        category: recipe.drink.category,
        alcoholic: recipe.drink.alcoholic
      },
      ingredients: recipe.recipe_ingredients.map do |recipe_ingredient|
        {
          name: recipe_ingredient.ingredient.name,
          amount: recipe_ingredient.amount,
          measurement_unit: recipe_ingredient.measurement_unit
        }
      end,
      publicly_visible: recipe.publicly_visible
    }
  end

  def self.format_collection(recipes)
    recipes.map do |recipe|
      format(recipe)
    end
  end
end