require "rails_helper"

RSpec.describe RecipeIngredient, type: :model do
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
    it "connects a recipe to an ingredient" do
      drink = create_drink(
        @user,
        {
          name: "Old Fashioned",
          alcoholic: true
        },
        category_names: [ "Whiskey" ]
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir with ice and strain over a large cube.",
      )

      ingredient = Ingredient.create!(
        name: "Bourbon",
        user: @user,
      )

      recipe_ingredient = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 2,
        measurement_unit: "oz",
      )

      expect(recipe_ingredient.recipe).to eq(recipe)
      expect(recipe_ingredient.ingredient).to eq(ingredient)
    end
  end

  describe "attributes" do
    it "stores the amount and measurement unit" do
      drink = create_drink(
        @user,
        {
          name: "Old Fashioned",
          alcoholic: true
        },
        category_names: [ "Whiskey" ]
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir with ice and strain over a large cube.",
      )

      ingredient = Ingredient.create!(
        name: "Bourbon",
        user: @user,
      )

      recipe_ingredient = RecipeIngredient.create!(
        recipe: recipe,
        ingredient: ingredient,
        amount: 2,
        measurement_unit: "oz",
      )

      expect(recipe_ingredient.amount).to eq(2)
      expect(recipe_ingredient.measurement_unit).to eq("oz")
    end
  end

  describe "validations" do
    before(:each) do
      drink = create_drink(
        @user,
        {
          name: "Old Fashioned",
          alcoholic: true
        },
        category_names: [ "Whiskey" ]
      )

      @recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir with ice and strain over a large cube.",
      )

      @ingredient = Ingredient.create!(
        name: "Bourbon",
        user: @user,
      )
    end

    it "requires an amount" do
      recipe_ingredient = RecipeIngredient.new(
        recipe: @recipe,
        ingredient: @ingredient,
        amount: nil,
        measurement_unit: "oz",
      )

      expect(recipe_ingredient).not_to be_valid
      expect(
        recipe_ingredient.errors[:amount]
      ).to include("can't be blank")
    end

    it "requires a measurement unit" do
      recipe_ingredient = RecipeIngredient.new(
        recipe: @recipe,
        ingredient: @ingredient,
        amount: 2,
        measurement_unit: nil,
      )

      expect(recipe_ingredient).not_to be_valid
      expect(
        recipe_ingredient.errors[:measurement_unit]
      ).to include("can't be blank")
    end
  end
end
