require "rails_helper"

RSpec.describe Ingredient, type: :model do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: "12345",
      password_confirmation: "12345",
    )
  end

  describe "relationships" do
    it "has many recipe_ingredients" do
      drink = create_drink(
        @user,
        {
          name: "Whiskey Sour",
          alcoholic: true
        },
        category_names: [ "Whiskey" ]
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Whiskey Sour",
        instructions: "Shake with ice and strain.",
      )

      ingredient = Ingredient.create!(
        name: "Lemon Juice",
        user: @user,
      )

      recipe_ingredient1 = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 1,
        measurement_unit: "oz",
      )

      recipe_ingredient2 = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 2,
        measurement_unit: "oz",
      )

      expect(ingredient.recipe_ingredients).to include(
        recipe_ingredient1,
        recipe_ingredient2
      )
    end

    it "has many recipes through recipe_ingredients" do
      whiskey_sour = create_drink(
        @user,
        {
          name: "Whiskey Sour",
          alcoholic: true
        },
        category_names: [ "Whiskey" ]
      )

      bee_knees = create_drink(
        @user,
        {
          name: "Bee's Knees",
          alcoholic: true
        },
        category_names: [ "Gin" ]
      )

      recipe1 = Recipe.create!(
        drink: whiskey_sour,
        name: "Classic Whiskey Sour",
        instructions: "Shake with ice and strain.",
      )

      recipe2 = Recipe.create!(
        drink: bee_knees,
        name: "Classic Bee's Knees",
        instructions: "Shake with ice and strain.",
      )

      ingredient = Ingredient.create!(
        name: "Lemon Juice",
        user: @user,
      )

      RecipeIngredient.create!(
        recipe: recipe1,
        ingredient: ingredient,
        amount: 1,
        measurement_unit: "oz",
      )

      RecipeIngredient.create!(
        recipe: recipe2,
        ingredient: ingredient,
        amount: 0.75,
        measurement_unit: "oz",
      )

      expect(ingredient.recipes).to contain_exactly(
        recipe1,
        recipe2
      )
    end
  end

  describe "validations" do
    it "is valid with a name" do
      ingredient = Ingredient.new(
        name: "Bourbon",
        user: @user,
      )

      expect(ingredient).to be_valid
    end

    it "is invalid without a name" do
      ingredient = Ingredient.new(
        name: nil,
        user: @user,
      )

      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:name]).to include(
        "can't be blank"
      )
    end

    it "does not allow duplicate names" do
      Ingredient.create!(
        name: "Bourbon",
        user: @user,
      )

      duplicate = Ingredient.new(
        name: "Bourbon",
        user: @user,
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include(
        "has already been taken"
      )
    end

    it "does not allow duplicate names with different capitalization" do
      Ingredient.create!(
        name: "Bourbon",
        user: @user,
      )

      duplicate = Ingredient.new(
        name: "bourbon",
        user: @user,
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include(
        "has already been taken"
      )
    end
  end
end
