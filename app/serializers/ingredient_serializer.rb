class IngredientSerializer
  def self.format(ingredient)
    {
      id: ingredient.id,
      name: ingredient.name,
      recipe_count: ingredient.recipe_ingredients.count
    }
  end

  def self.format_collection(ingredients)
    ingredients.map do |ingredient|
      format(ingredient)
    end
  end
end
