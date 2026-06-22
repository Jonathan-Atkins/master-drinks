require "rails_helper"

RSpec.describe RecipeIngredient, type: :model do
  describe "relationships" do
    it "connects a recipe to an ingredient" do
      drink = Drink.create!(
        name: "Old Fashioned",
        category: "whiskey",
        alcoholic: true
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir with ice and strain over a large cube."
      )

      ingredient = Ingredient.create!(
        name: "Bourbon"
      )

      recipe_ingredient = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 2,
        measurement_unit: "oz"
      )

      expect(recipe_ingredient.recipe).to eq(recipe)
      expect(recipe_ingredient.ingredient).to eq(ingredient)
    end
  end

  describe "attributes" do
    it "stores the amount and measurement unit" do
      drink = Drink.create!(
        name: "Old Fashioned",
        category: "whiskey",
        alcoholic: true
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir with ice and strain over a large cube."
      )

      ingredient = Ingredient.create!(
        name: "Bourbon"
      )

      recipe_ingredient = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 2,
        measurement_unit: "oz"
      )

      expect(recipe_ingredient.amount).to eq(2)
      expect(recipe_ingredient.measurement_unit).to eq("oz")
    end
  end
end
