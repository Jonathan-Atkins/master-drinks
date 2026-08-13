class RecipeSerializer
  def self.format(recipe, current_user)
    user_recipe = current_user.user_recipes.find_by(recipe_id: recipe.id)

    {
      id: recipe.id,
      name: recipe.name,
      instructions: recipe.instructions,

      owned_by_current_user: recipe.drink.user_id == current_user.id,
      saved_by_current_user: user_recipe.present?,
      user_recipe_id: user_recipe&.id,

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

  def self.format_collection(recipes, current_user)
    recipes.map do |recipe|
      format(recipe, current_user)
    end
  end
end