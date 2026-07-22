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
    describe "GET /api/v1/recipes" do
      it "returns all recipes" do
        Recipe.create!(
          drink: @other_drink,
          name: "Classic Margarita",
          instructions: "Shake with ice and strain."
        )

        log_in(@user)

        get "/api/v1/recipes"

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result.count).to eq(2)

        expect(result.pluck("name")).to include(
          "Classic Old Fashioned",
          "Classic Margarita"
        )
      end

      it "returns recipes filtered by drink name" do
        Recipe.create!(
          drink: @drink,
          name: "Maple Old Fashioned",
          instructions: "Stir with maple syrup and ice."
        )

        Recipe.create!(
          drink: @other_drink,
          name: "Classic Margarita",
          instructions: "Shake with ice and strain."
        )

        bourbon = Ingredient.create!(name: "Bourbon")

        RecipeIngredient.create!(
          recipe: @recipe,
          ingredient: bourbon,
          amount: 2.0,
          measurement_unit: "oz"
        )

        log_in(@user)

        get "/api/v1/recipes", params: {
          drink_name: "old fashioned"
        }

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result.count).to eq(2)

        expect(result.pluck("name")).to include(
          "Classic Old Fashioned",
          "Maple Old Fashioned"
        )

        expect(result.pluck("name")).not_to include("Classic Margarita")

        classic_recipe = result.find do |recipe|
          recipe["name"] == "Classic Old Fashioned"
        end

        expect(classic_recipe["drink"]["id"]).to eq(@drink.id)
        expect(classic_recipe["drink"]["name"]).to eq("Old Fashioned")
        expect(classic_recipe["drink"]["username"]).to eq("alice")

        expect(classic_recipe["ingredients"].count).to eq(1)
        expect(classic_recipe["ingredients"].first["name"]).to eq("Bourbon")
        expect(classic_recipe["ingredients"].first["amount"]).to eq("2.0")
        expect(classic_recipe["ingredients"].first["measurement_unit"]).to eq("oz")
      end

      it "does not return private recipes" do
        private_recipe = Recipe.create!(
          drink: @other_drink,
          name: "Private Margarita",
          instructions: "Private instructions.",
          publicly_visible: false
        )

        log_in(@user)

        get "/api/v1/recipes"

        result = JSON.parse(response.body)
        recipe_ids = result.pluck("id")

        expect(response).to have_http_status(:ok)
        expect(recipe_ids).to include(@recipe.id)
        expect(recipe_ids).not_to include(private_recipe.id)
      end
    end

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

        expect(result.pluck("name")).to include(
          "Classic Old Fashioned",
          "Maple Old Fashioned"
        )

        expect(result.first["drink"]["id"]).to eq(@drink.id)
        expect(result.first["drink"]["name"]).to eq("Old Fashioned")
        expect(result.first["drink"]["username"]).to eq("alice")
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
        expect(result["drink"]["username"]).to eq("alice")
      end
      it "allows the owner to view their private recipe" do
        @recipe.update!(publicly_visible: false)

        log_in(@user)

        get "/api/v1/recipes/#{@recipe.id}"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["id"]).to eq(@recipe.id)
      end
      it "allows another user to view a public recipe" do
        log_in(@other_user)

        get "/api/v1/recipes/#{@recipe.id}"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["id"]).to eq(@recipe.id)
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
        expect(result["drink"]["username"]).to eq("alice")

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
      it "allows the owner to make their recipe private" do
        log_in(@user)

        patch "/api/v1/recipes/#{@recipe.id}",
              params: { publicly_visible: false }

        result = JSON.parse(response.body)
        @recipe.reload

        expect(response).to have_http_status(:ok)
        expect(@recipe.publicly_visible).to be(false)
      end

      it "allows the owner to make their recipe public again" do
        @recipe.update!(publicly_visible: false)

        log_in(@user)

        patch "/api/v1/recipes/#{@recipe.id}",
              params: { publicly_visible: true }

        result = JSON.parse(response.body)
        @recipe.reload

        expect(response).to have_http_status(:ok)
        expect(@recipe.publicly_visible).to be(true)
      end
      
      it "allows the owner to update the privacy of their recipe" do
        log_in(@user)

        patch "/api/v1/recipes/#{@recipe.id}",
            params: { publicly_visible: false }
        
        result = JSON.parse(response.body)
        @recipe.reload

        expect(result["publicly_visible"]).to eq(false)
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
      it "does not allow an unauthenticated user to list all recipes" do
        get "/api/v1/recipes"

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow an unauthenticated user to search recipes by drink name" do
        get "/api/v1/recipes", params: {
          drink_name: "old fashioned"
        }

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow an unauthenticated user to list recipes for a drink" do
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

    describe "GET /api/v1/recipes search" do
      it "returns an empty array when no recipes match the drink name" do
        log_in(@user)

        get "/api/v1/recipes", params: {
          drink_name: "negroni"
        }

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result).to eq([])
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
      it "does not allow another user to view a private recipe" do
        @recipe.update!(publicly_visible: false)

        log_in(@other_user)

        get "/api/v1/recipes/#{@recipe.id}"

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

    describe "PATCH /api/v1/recipes/:id" do
      it "does not allow another user to change recipe visibility" do
        log_in(@other_user)

        patch "/api/v1/recipes/#{@recipe.id}",
              params: { publicly_visible: false }

        result = JSON.parse(response.body)
        @recipe.reload

        expect(response).to have_http_status(:forbidden)
        expect(@recipe.publicly_visible).to be(true)
        expect(result["errors"]).to include(
          "You are not authorized to modify this recipe"
        )
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
