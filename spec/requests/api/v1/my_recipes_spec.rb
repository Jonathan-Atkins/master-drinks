require "rails_helper"

RSpec.describe "My Recipes API", type: :request do
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

    @drink = @user.drinks.create!(
      name: "Old Fashioned",
      category: "whiskey",
      alcoholic: true
    )

    @recipe = Recipe.create!(
      drink: @drink,
      name: "Classic Old Fashioned",
      instructions: "Stir with ice and strain over a large cube."
    )

    @other_drink = @other_user.drinks.create!(
      name: "Margarita",
      category: "tequila",
      alcoholic: true
    )

    @other_recipe = Recipe.create!(
      drink: @other_drink,
      name: "Classic Margarita",
      instructions: "Shake with ice and strain."
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
      email: user.email,
      password: "password123"
    }
  end

  describe "happy path" do
    describe "GET /api/v1/my_recipes" do
      it "returns recipes owned by the logged-in user through their drinks" do
        log_in(@user)

        get "/api/v1/my_recipes"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result).to be_an(Array)
        expect(result.count).to eq(1)
        expect(result.first["id"]).to eq(@recipe.id)
        expect(result.first["name"]).to eq("Classic Old Fashioned")
      end

      it "does not return recipes owned by another user" do
        log_in(@user)

        get "/api/v1/my_recipes"

        result = JSON.parse(response.body)
        recipe_ids = result.pluck("id")

        expect(response).to have_http_status(:ok)
        expect(recipe_ids).to include(@recipe.id)
        expect(recipe_ids).not_to include(@other_recipe.id)
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/my_recipes" do
      it "returns an empty array when the logged-in user owns no recipes" do
        @recipe.destroy!

        log_in(@user)

        get "/api/v1/my_recipes"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result).to eq([])
      end

      it "returns unauthorized when the user is not logged in" do
        get "/api/v1/my_recipes"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(result["errors"]).to include("You must be logged in")
      end
    end
  end
end
