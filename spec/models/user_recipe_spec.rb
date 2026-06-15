require "rails_helper"

RSpec.describe UserRecipe, type: :model do
  describe "relationships" do
    it "connects a user to a recipe" do
      user = User.create!(
        name: "Jonathan",
        username: "jonathan",
        email: "jonathan@example.com",
        password_digest: "password"
      )

      drink = Drink.create!(
        name: "Margarita",
        category: "tequila",
        alcoholic: true
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Margarita",
        instructions: "Shake with ice and strain."
      )

      user_recipe = UserRecipe.create!(
        user: user,
        recipe: recipe
      )

      expect(user_recipe.user).to eq(user)
      expect(user_recipe.recipe).to eq(recipe)
    end
  end

  describe "validations" do
    it "does not allow the same user to save the same recipe twice" do
      user = User.create!(
        name: "Jonathan",
        username: "jonathan",
        email: "jonathan@example.com",
        password_digest: "password"
      )

      drink = Drink.create!(
        name: "Margarita",
        category: "tequila",
        alcoholic: true
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Margarita",
        instructions: "Shake with ice and strain."
      )

      UserRecipe.create!(
        user: user,
        recipe: recipe
      )

      duplicate = UserRecipe.new(
        user: user,
        recipe: recipe
      )


      expect(duplicate).to_not be_valid
      expect(duplicate.errors.full_messages).to include("Recipe has already been taken")
    end
  end
end