require "rails_helper"

RSpec.describe "Api::V1::Recipes", type: :request do
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

    @other_drink = @other_user.drinks.create!(
      name: "Margarita",
      category: "tequila",
      alcoholic: true
    )

    @recipe = Recipe.create!(
      drink: @drink,
      name: "Classic Old Fashioned",
      instructions: "Stir with ice and strain over a large cube."
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
      email: user.email,
      password: "password123"
    }
  end

  describe "happy path" do
    describe "GET /api/v1/drinks/:drink_id/recipes" do
      it "returns all recipes associated with the drink" do
        Recipe.create!(
          drink: @drink,
          name: "Maple Old Fashioned",
          instructions: "Stir with maple syrup and ice."
        )

        log_in(@user)

        get "/api/v1/drinks/#{@drink.id}/recipes"

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)
      
        expect(result.count).to eq(2)
        # require 'pry-nav'; binding.pry
        expect(result.pluck("name")).to include(
          "Classic Old Fashioned",
          "Maple Old Fashioned"
        )

        expect(result.first["drink"]["id"]).to eq(@drink.id)
        expect(result.first["drink"]["name"]).to eq("Old Fashioned")
      end
    end

    describe "GET /api/v1/recipes/:id" do
      it "returns one recipe with its associated drink" do
        log_in(@user)

        get "/api/v1/recipes/#{@recipe.id}"

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result["id"]).to eq(@recipe.id)
        expect(result["name"]).to eq("Classic Old Fashioned")
        expect(result["instructions"]).to eq(
          "Stir with ice and strain over a large cube."
        )

        expect(result["drink"]["id"]).to eq(@drink.id)
        expect(result["drink"]["name"]).to eq("Old Fashioned")
      end
    end

    describe "POST /api/v1/drinks/:drink_id/recipes" do
      it "allows the drink owner to create a recipe" do
        log_in(@user)

        post "/api/v1/drinks/#{@drink.id}/recipes", params: {
          name: "Smoked Old Fashioned",
          instructions: "Stir with ice and smoke before serving."
        }

        expect(response).to have_http_status(:created)

        result = JSON.parse(response.body)

        expect(result["name"]).to eq("Smoked Old Fashioned")
        expect(result["instructions"]).to eq(
          "Stir with ice and smoke before serving."
        )

        expect(result["drink"]["id"]).to eq(@drink.id)
        expect(result["drink"]["name"]).to eq("Old Fashioned")

        expect(Recipe.last.drink).to eq(@drink)
      end
    end

    describe "PATCH /api/v1/recipes/:id" do
      it "allows the drink owner to update the recipe" do
        log_in(@user)

        patch "/api/v1/recipes/#{@recipe.id}", params: {
          name: "Updated Old Fashioned",
          instructions: "Stir with ice for thirty seconds."
        }

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result["name"]).to eq("Updated Old Fashioned")
        expect(result["instructions"]).to eq(
          "Stir with ice for thirty seconds."
        )

        expect(@recipe.reload.name).to eq("Updated Old Fashioned")
      end
    end

    describe "DELETE /api/v1/recipes/:id" do
      it "allows the drink owner to delete the recipe" do
        log_in(@user)

        expect {
          delete "/api/v1/recipes/#{@recipe.id}"
        }.to change(Recipe, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe "sad path" do
    describe "authentication" do
      it "does not allow an unauthenticated user to list recipes" do
        get "/api/v1/drinks/#{@drink.id}/recipes"

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow an unauthenticated user to view a recipe" do
        get "/api/v1/recipes/#{@recipe.id}"

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow an unauthenticated user to create a recipe" do
        post "/api/v1/drinks/#{@drink.id}/recipes", params: {
          name: "Smoked Old Fashioned",
          instructions: "Stir with ice."
        }

        expect(response).to have_http_status(:unauthorized)
        expect(
          Recipe.find_by(name: "Smoked Old Fashioned")
        ).to be_nil
      end

      it "does not allow an unauthenticated user to update a recipe" do
        patch "/api/v1/recipes/#{@recipe.id}", params: {
          name: "Unauthorized Update"
        }

        expect(response).to have_http_status(:unauthorized)
        expect(@recipe.reload.name).to eq("Classic Old Fashioned")
      end

      it "does not allow an unauthenticated user to delete a recipe" do
        expect {
          delete "/api/v1/recipes/#{@recipe.id}"
        }.not_to change(Recipe, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "authorization" do
      it "does not allow a user to create a recipe for another user's drink" do
        log_in(@other_user)

        post "/api/v1/drinks/#{@drink.id}/recipes", params: {
          name: "Unauthorized Recipe",
          instructions: "This should not be created."
        }

        expect(response).to have_http_status(:forbidden)
        expect(
          Recipe.find_by(name: "Unauthorized Recipe")
        ).to be_nil
      end

      it "does not allow a user to update another user's recipe" do
        log_in(@other_user)

        patch "/api/v1/recipes/#{@recipe.id}", params: {
          name: "Unauthorized Update"
        }

        expect(response).to have_http_status(:forbidden)
        expect(@recipe.reload.name).to eq("Classic Old Fashioned")
      end

      it "does not allow a user to delete another user's recipe" do
        log_in(@other_user)

        expect {
          delete "/api/v1/recipes/#{@recipe.id}"
        }.not_to change(Recipe, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "GET /api/v1/drinks/:drink_id/recipes" do
      it "returns 404 when the drink does not exist" do
        log_in(@user)

        get "/api/v1/drinks/999999/recipes"

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "GET /api/v1/recipes/:id" do
      it "returns 404 when the recipe does not exist" do
        log_in(@user)

        get "/api/v1/recipes/999999"

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "POST /api/v1/drinks/:drink_id/recipes" do
      it "does not create a recipe with invalid attributes" do
        log_in(@user)

        post "/api/v1/drinks/#{@drink.id}/recipes", params: {
          name: nil,
          instructions: "Stir with ice."
        }

        expect(response).to have_http_status(:unprocessable_content)

        result = JSON.parse(response.body)

        expect(result["errors"]).to include("Name can't be blank")
      end
    end

    describe "PATCH /api/v1/recipes/:id" do
      it "does not update a recipe with invalid attributes" do
        log_in(@user)

        patch "/api/v1/recipes/#{@recipe.id}", params: {
          name: nil
        }

        expect(response).to have_http_status(:unprocessable_content)

        result = JSON.parse(response.body)

        expect(result["errors"]).to include("Name can't be blank")
        expect(@recipe.reload.name).to eq("Classic Old Fashioned")
      end

      it "returns 404 when the recipe does not exist" do
        log_in(@user)

        patch "/api/v1/recipes/999999", params: {
          name: "Missing Recipe"
        }

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "DELETE /api/v1/recipes/:id" do
      it "returns 404 when the recipe does not exist" do
        log_in(@user)

        delete "/api/v1/recipes/999999"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
