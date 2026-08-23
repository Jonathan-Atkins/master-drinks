module IngredientHelpers
  def create_ingredient(user, attributes = {}, ingredient_type: "Spirit", flavor_profiles: [ "Rich" ])
    Ingredient.create!(
      {
        name: "Bourbon",
        user: user,
        ingredient_type: ingredient_type,
        flavor_profiles: flavor_profiles
      }.merge(attributes)
    )
  end
end

RSpec.configure do |config|
  config.include IngredientHelpers
end
