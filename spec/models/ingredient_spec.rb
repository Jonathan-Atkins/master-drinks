require "rails_helper"

RSpec.describe Ingredient, type: :model do
  describe "relationships" do
    it "has many recipe_ingredients" do
      drink = Drink.create!(name: "Whiskey Sour", category: "whiskey", alcoholic: true)

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Whiskey Sour",
        instructions: "Shake with ice and strain."
      )

      ingredient = Ingredient.create!(name: "Lemon Juice")

      recipe_ingredient1 = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 1,
        measurement_unit: "oz"
      )

      recipe_ingredient2 = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 2,
        measurement_unit: "oz"
      )

      expect(ingredient.recipe_ingredients).to include(recipe_ingredient1, recipe_ingredient2)
    end

    it "has many recipes through recipe_ingredients" do
      whiskey_sour = Drink.create!(name: "Whiskey Sour", category: "whiskey", alcoholic: true)
      bee_knees = Drink.create!(name: "Bee's Knees", category: "gin", alcoholic: true)

      recipe1 = Recipe.create!(
        drink: whiskey_sour,
        name: "Classic Whiskey Sour",
        instructions: "Shake with ice and strain."
      )

      recipe2 = Recipe.create!(
        drink: bee_knees,
        name: "Classic Bee's Knees",
        instructions: "Shake with ice and strain."
      )

      ingredient = Ingredient.create!(name: "Lemon Juice")

      RecipeIngredient.create!(
        recipe: recipe1,
        ingredient: ingredient,
        amount: 1,
        measurement_unit: "oz"
      )

      RecipeIngredient.create!(
        recipe: recipe2,
        ingredient: ingredient,
        amount: 0.75,
        measurement_unit: "oz"
      )

      expect(ingredient.recipes).to contain_exactly(recipe1, recipe2)
    end
  end
end