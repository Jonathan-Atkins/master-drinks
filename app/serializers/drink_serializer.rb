class RecipeSerializer
  def self.format(drink)
    {
      id: drink.id,
      name: drink.name,
      category: drink.category,
      alcoholic: drink.alcoholic,
      recipe_count: drink.recipes.count
    }
  end
  
  def self.format_collection(drinks)
    drinks.map do |drink|
      format(drink)
    end
  end
end