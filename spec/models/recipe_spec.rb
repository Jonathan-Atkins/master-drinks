require "rails_helper"

RSpec.describe Recipe, type: :model do
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
    it "belongs to a drink" do
      drink = @user.drinks.create!(
        name: "Old Fashioned",
        category: "whiskey",
        alcoholic: true
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube."
      )

      expect(recipe.drink).to eq(drink)
    end

    it "has many ingredients through recipe_ingredients" do
      drink = @user.drinks.create!(
        name: "Old Fashioned",
        category: "whiskey",
        alcoholic: true
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube."
      )

      bourbon = Ingredient.create!(name: "Bourbon")
      bitters = Ingredient.create!(name: "Bitters")

      RecipeIngredient.create!(
        recipe: recipe,
        ingredient: bourbon,
        amount: 2,
        measurement_unit: "oz"
      )

      RecipeIngredient.create!(
        recipe: recipe,
        ingredient: bitters,
        amount: 2,
        measurement_unit: "dashes"
      )

      expect(recipe.ingredients).to contain_exactly(bourbon, bitters)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      drink = @user.drinks.create!(
        name: "Old Fashioned",
        category: "whiskey",
        alcoholic: true
      )

      recipe = Recipe.new(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube."
      )

      expect(recipe).to be_valid
    end

    it "requires a name" do
      drink = @user.drinks.create!(
        name: "Old Fashioned",
        category: "whiskey",
        alcoholic: true
      )

      recipe = Recipe.new(
        drink: drink,
        name: nil,
        instructions: "Stir ingredients with ice and strain over a large cube."
      )

      expect(recipe).not_to be_valid
      expect(recipe.errors.full_messages).to include("Name can't be blank")
    end

    it "requires a drink" do
      recipe = Recipe.new(
        drink: nil,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube."
      )

      expect(recipe).not_to be_valid
      expect(recipe.errors.full_messages).to include("Drink must exist")
    end
  end
end
