class IngredientSerializer
  def self.format(ingredient, current_user = nil)
    {
      id: ingredient.id,
      name: ingredient.name,
      ingredient_type: ingredient.ingredient_type,
      flavor_profiles: ingredient.flavor_profiles,
      recipe_count: ingredient.recipe_ingredients.count,
      owned_by_current_user: current_user.present? &&
                             ingredient.user_id == current_user.id
    }
  end

  def self.format_collection(ingredients, current_user = nil)
    ingredients.map do |ingredient|
      format(ingredient, current_user)
    end
  end
end
