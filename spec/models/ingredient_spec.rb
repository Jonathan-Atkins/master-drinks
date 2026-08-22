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

  def create_test_ingredient(attributes = {})
    create_ingredient(
      @user,
      attributes,
      ingredient_type: "Spirit",
      flavor_profiles: ["Rich"],
    )
  end

  describe "relationships" do
    it "has many recipe_ingredients" do
      drink = create_drink(
        @user,
        {
          name: "Whiskey Sour",
          alcoholic: true,
        },
        category_names: ["Whiskey"],
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Whiskey Sour",
        instructions: "Shake with ice and strain.",
      )

      ingredient = create_ingredient(
        @user,
        {
          name: "Lemon Juice",
          ingredient_type: "Juice",
          flavor_profiles: ["Citrusy"],
        }
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
          alcoholic: true,
        },
        category_names: ["Whiskey"],
      )

      bee_knees = create_drink(
        @user,
        {
          name: "Bee's Knees",
          alcoholic: true,
        },
        category_names: ["Gin"],
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

      ingredient = create_ingredient(
        @user,
        {
          name: "Lemon Juice",
          ingredient_type: "Juice",
          flavor_profiles: ["Citrusy"],
        }
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

    it "destroys its recipe_ingredients when destroyed" do
      drink = create_drink(
        @user,
        {
          name: "Whiskey Sour",
          alcoholic: true,
        },
        category_names: ["Whiskey"],
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Whiskey Sour",
        instructions: "Shake with ice.",
      )

      ingredient = create_ingredient(
        @user,
        {
          name: "Lemon Juice",
          ingredient_type: "Juice",
          flavor_profiles: ["Citrusy"],
        }
      )

      recipe_ingredient = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 1,
        measurement_unit: "oz",
      )

      ingredient.destroy

      expect(RecipeIngredient.exists?(recipe_ingredient.id)).to be(false)
      expect(Recipe.exists?(recipe.id)).to be(true)
    end
  end

  describe "validations" do
    it "is valid with a name" do
      ingredient = Ingredient.new(
        name: "Bourbon",
        user: @user,
        ingredient_type: "Spirit",
        flavor_profiles: ["Rich"],
      )

      expect(ingredient).to be_valid
    end

    it "is valid with an approved ingredient type" do
      ingredient = Ingredient.new(
        name: "Dry Vermouth",
        user: @user,
        ingredient_type: "Wine",
        flavor_profiles: ["Dry"],
      )

      expect(ingredient).to be_valid
    end

    it "is invalid with an unapproved ingredient type" do
      ingredient = Ingredient.new(
        name: "Mystery Ingredient",
        user: @user,
        ingredient_type: "Potion",
        flavor_profiles: ["Sweet"],
      )

      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:ingredient_type]).to include(
        "is not included in the list"
      )
    end

    it "is valid with approved flavor profiles" do
      ingredient = Ingredient.new(
        name: "Orange Bitters",
        user: @user,
        ingredient_type: "Bitters",
        flavor_profiles: ["Bitter", "Citrusy"],
      )

      expect(ingredient).to be_valid
    end

    it "is valid with multiple approved flavor profiles" do
      ingredient = Ingredient.new(
        name: "Spiced Rum",
        user: @user,
        ingredient_type: "Spirit",
        flavor_profiles: ["Sweet", "Spicy", "Tropical"],
      )

      expect(ingredient).to be_valid
    end

    it "is invalid with an unapproved flavor profile" do
      ingredient = Ingredient.new(
        name: "Cursed Syrup",
        user: @user,
        ingredient_type: "Syrup",
        flavor_profiles: ["Sweet", "Alien"],
      )

      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:flavor_profiles]).to include(
        "contains invalid values: Alien"
      )
    end

    it "is invalid without a name" do
      ingredient = Ingredient.new(
        name: nil,
        user: @user,
        ingredient_type: "Spirit",
        flavor_profiles: ["Rich"],
      )

      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:name]).to include(
        "can't be blank"
      )
    end

    it "does not allow duplicate names" do
      create_test_ingredient(name: "Bourbon")

      duplicate = Ingredient.new(
        name: "Bourbon",
        user: @user,
        ingredient_type: "Spirit",
        flavor_profiles: ["Rich"],
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include(
        "has already been taken"
      )
    end

    it "does not allow duplicate names with different capitalization" do
      create_test_ingredient(name: "Bourbon")

      duplicate = Ingredient.new(
        name: "bourbon",
        user: @user,
        ingredient_type: "Spirit",
        flavor_profiles: ["Rich"],
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include(
        "has already been taken"
      )
    end
  end
end
