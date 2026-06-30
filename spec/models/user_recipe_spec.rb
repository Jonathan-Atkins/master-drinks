require "rails_helper"

RSpec.describe UserRecipe, type: :model do
  before(:each) do
    @user = User.create!(
      name: "Jonathan",
      username: "jonathan",
      email: "jonathan@example.com",
      password: "password",
      password_confirmation: "password"
    )

    @drink = @user.drinks.create!(
      name: "Margarita",
      category: "tequila",
      alcoholic: true
    )

    @recipe = Recipe.create!(
      drink: @drink,
      name: "Classic Margarita",
      instructions: "Shake with ice and strain."
    )
  end

  describe "relationships" do
    it "connects a user to a recipe" do
      user_recipe = UserRecipe.create!(
        user: @user,
        recipe: @recipe
      )

      expect(user_recipe.user).to eq(@user)
      expect(user_recipe.recipe).to eq(@recipe)
    end
  end

  describe "validations" do
    it "does not allow the same user to save the same recipe twice" do
      UserRecipe.create!(
        user: @user,
        recipe: @recipe
      )

      duplicate = UserRecipe.new(
        user: @user,
        recipe: @recipe
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors.full_messages).to include(
        "Recipe has already been taken"
      )
    end
  end
end
