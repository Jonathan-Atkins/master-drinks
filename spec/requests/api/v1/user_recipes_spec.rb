require "rails_helper"

RSpec.describe "Api::V1::UserRecipes", type: :request do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @other_user = User.create!(
      name: "Bob",
      username: "bob",
      email: "bob@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @drink = @other_user.drinks.create!(
      name: "Old Fashioned",
      category: "whiskey",
      alcoholic: true
    )

    @recipe = Recipe.create!(
      drink: @drink,
      name: "Classic Old Fashioned",
      instructions: "Stir with ice and strain over a large cube."
    )

    @ingredient = Ingredient.create!(
      name: "Burbon"
    )

    @recipe_ingredient = RecipeIngredient.create!(
      recipe: @recipe,
      ingredient: @ingredient,
      amount: 2.0,
      measurement_unit: "oz"
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
      email: user.email,
      password: "password123"
    }
  end

  describe "happy path" do
    describe "GET /api/v1/user_recipes" do
      it "returns the logged-in user's saved recipes" do
        log_in(@user)

        UserRecipe.create!(user: @user, recipe: @recipe)

        get "/api/v1/user_recipes"

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result.count).to eq(1)
        expect(result.first["name"]).to eq("Classic Old Fashioned")
      end
    end

    describe "POST /api/v1/user_recipes" do
      it "allows a logged-in user to save a recipe" do
        log_in(@user)

        expect {
          post "/api/v1/user_recipes", params: {
            recipe_id: @recipe.id
          }
        }.to change(UserRecipe, :count).by(1)

        expect(response).to have_http_status(:created)

        result = JSON.parse(response.body)

        expect(result["name"]).to eq("Classic Old Fashioned")
        expect(UserRecipe.last.user).to eq(@user)
        expect(UserRecipe.last.recipe).to eq(@recipe)
      end
    end

    describe "DELETE /api/v1/user_recipes/:id" do
      it "allows a logged-in user to remove a saved recipe" do
        log_in(@user)

        user_recipe = UserRecipe.create!(
          user: @user,
          recipe: @recipe
        )

        expect {
          delete "/api/v1/user_recipes/#{user_recipe.id}"
        }.to change(UserRecipe, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/user_recipes" do
      it "does not allow an unauthenticated user to view saved recipes" do
        get "/api/v1/user_recipes"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "POST /api/v1/user_recipes" do
      it "does not allow an unauthenticated user to save a recipe" do
        expect {
          post "/api/v1/user_recipes", params: {
            recipe_id: @recipe.id
          }
        }.not_to change(UserRecipe, :count)

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow a user to save the same recipe twice" do
        log_in(@user)

        UserRecipe.create!(
          user: @user,
          recipe: @recipe
        )

        expect {
          post "/api/v1/user_recipes", params: {
            recipe_id: @recipe.id
          }
        }.not_to change(UserRecipe, :count)

        expect(response).to have_http_status(:unprocessable_content)

        result = JSON.parse(response.body)

        expect(result["errors"]).to include("Recipe has already been taken")
      end

      it "returns 404 when the recipe does not exist" do
        log_in(@user)

        post "/api/v1/user_recipes", params: {
          recipe_id: 999999
        }

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "DELETE /api/v1/user_recipes/:id" do
      it "does not allow an unauthenticated user to remove a saved recipe" do
        user_recipe = UserRecipe.create!(
          user: @user,
          recipe: @recipe
        )

        expect {
          delete "/api/v1/user_recipes/#{user_recipe.id}"
        }.not_to change(UserRecipe, :count)

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow a user to remove another user's saved recipe" do
        log_in(@other_user)

        user_recipe = UserRecipe.create!(
          user: @user,
          recipe: @recipe
        )

        expect {
          delete "/api/v1/user_recipes/#{user_recipe.id}"
        }.not_to change(UserRecipe, :count)

        expect(response.status).to be(404)
      end

      it "returns 404 when the saved recipe does not exist" do
        log_in(@user)

        delete "/api/v1/user_recipes/999999"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
