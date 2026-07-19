require "rails_helper"

RSpec.describe Ingredient, type: :model do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: "12345",
      password_confirmation: "12345"
    )
  end

  describe "relationships" do
    it "has many recipe_ingredients" do
      drink = @user.drinks.create!(
        name: "Whiskey Sour",
        category: "whiskey",
        alcoholic: true
      )

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

      expect(ingredient.recipe_ingredients).to include(
        recipe_ingredient1,
        recipe_ingredient2
      )
    end

    it "has many recipes through recipe_ingredients" do
      whiskey_sour = @user.drinks.create!(
        name: "Whiskey Sour",
        category: "whiskey",
        alcoholic: true
      )

      bee_knees = @user.drinks.create!(
        name: "Bee's Knees",
        category: "gin",
        alcoholic: true
      )

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
  describe "validations" do
    it "is valid with a name" do
      ingredient = Ingredient.new(name: "Bourbon")

      expect(ingredient).to be_valid
    end

    it "is invalid without a name" do
      ingredient = Ingredient.new(name: nil)

      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:name]).to include("can't be blank")
    end

    it "does not allow duplicate names" do
      Ingredient.create!(name: "Bourbon")
      duplicate = Ingredient.new(name: "Bourbon")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "does not allow duplicate names with different capitalization" do
      Ingredient.create!(name: "Bourbon")
      duplicate = Ingredient.new(name: "bourbon")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end
  end
end
