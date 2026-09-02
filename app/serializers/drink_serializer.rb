class DrinkSerializer
  def self.format(drink)
    {
      id: drink.id,
      name: drink.name,

      categories:
        drink.categories.map do |category|
          {
            id: category.id,
            name: category.name,
            slug: category.slug,
            alcoholic:
              category.alcoholic,
            ingredient: {
              id:
                category.ingredient.id,
              name:
                category.ingredient.name
            }
          }
        end,

      alcoholic:
        drink.alcoholic,

      publicly_visible:
        drink.publicly_visible,

      recipe_count:
        drink.recipes.size,

      next_recipe_name:
        drink.next_recipe_name
    }
  end

  def self.format_collection(drinks)
    drinks.map do |drink|
      format(drink)
    end
  end
end
