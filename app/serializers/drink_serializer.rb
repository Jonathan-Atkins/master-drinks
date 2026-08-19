class DrinkSerializer
  def self.format(drink)
    {
      id: drink.id,
      name: drink.name,
      categories: drink.categories.map do |category|
        {
          name: category.name,
          slug: category.slug
        }
      end,
      alcoholic: drink.alcoholic,
      publicly_visible: drink.publicly_visible,
      recipe_count: drink.recipes.size
    }
  end

  def self.format_collection(drinks)
    drinks.map { |drink| format(drink) }
  end
end
