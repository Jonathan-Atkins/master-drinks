class DrinkSerializer
  def self.format(drink)
    {
      id: drink.id,
      name: drink.name,
      category: drink.category,
      alcoholic: drink.alcoholic,
      publicly_visible: drink.publicly_visible,
      recipe_count: drink.recipes.count
    }
  end

  def self.format_collection(drinks)
    drinks.map { |drink| format(drink) }
  end
end