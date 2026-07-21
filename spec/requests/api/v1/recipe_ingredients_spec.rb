require "rails_helper"

RSpec.describe "Api::V1::RecipeIngredients", type: :request do
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

    @other_recipe = Recipe.create!(
      drink: @other_drink,
      name: "Classic Margarita",
      instructions: "Shake with ice and strain."
    )

    @bourbon = Ingredient.create!(
      name: "Bourbon"
    )

    @bitters = Ingredient.create!(
      name: "Bitters"
    )

    @recipe_ingredient = RecipeIngredient.create!(
      recipe: @recipe,
      ingredient: @bourbon,
      amount: 2,
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
    describe "POST /api/v1/recipes/:recipe_id/recipe_ingredients" do
      it "allows the recipe owner to add an ingredient to the recipe" do
        log_in(@user)

        expect {
          post "/api/v1/recipes/#{@recipe.id}/recipe_ingredients",
               params: {
                 ingredient_id: @bitters.id,
                 amount: 2,
                 measurement_unit: "dashes"
               }
        }.to change(RecipeIngredient, :count).by(1)

        expect(response).to have_http_status(:created)

        result = JSON.parse(response.body)

        expect(result["name"]).to eq("Bitters")
        expect(result["amount"]).to eq(2.0)
        expect(result["measurement_unit"]).to eq("dashes")

        created_recipe_ingredient = RecipeIngredient.last

        expect(created_recipe_ingredient.recipe).to eq(@recipe)
        expect(created_recipe_ingredient.ingredient).to eq(@bitters)
      end
    end

    describe "PATCH /api/v1/recipe_ingredients/:id" do
      it "allows the recipe owner to update the amount and measurement unit" do
        log_in(@user)

        patch "/api/v1/recipe_ingredients/#{@recipe_ingredient.id}",
              params: {
                amount: 3,
                measurement_unit: "oz"
              }

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result["name"]).to eq("Bourbon")
        expect(result["amount"]).to eq(3)
        expect(result["measurement_unit"]).to eq("oz")

        @recipe_ingredient.reload

        expect(@recipe_ingredient.amount).to eq(3)
        expect(@recipe_ingredient.measurement_unit).to eq("oz")
      end
    end

    describe "DELETE /api/v1/recipe_ingredients/:id" do
      it "allows the recipe owner to remove an ingredient from the recipe" do
        log_in(@user)

        expect {
          delete "/api/v1/recipe_ingredients/#{@recipe_ingredient.id}"
        }.to change(RecipeIngredient, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe "sad path" do
    describe "POST /api/v1/recipes/:recipe_id/recipe_ingredients" do
      it "does not allow an unauthenticated user to add an ingredient" do
        expect {
          post "/api/v1/recipes/#{@recipe.id}/recipe_ingredients",
               params: {
                 ingredient_id: @bitters.id,
                 amount: 2,
                 measurement_unit: "dashes"
               }
        }.not_to change(RecipeIngredient, :count)

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow another user to add an ingredient to the recipe" do
        log_in(@other_user)

        expect {
          post "/api/v1/recipes/#{@recipe.id}/recipe_ingredients",
               params: {
                 ingredient_id: @bitters.id,
                 amount: 2,
                 measurement_unit: "dashes"
               }
        }.not_to change(RecipeIngredient, :count)

        expect(response).to have_http_status(:forbidden)
      end

      it "returns 404 when the recipe does not exist" do
        log_in(@user)

        post "/api/v1/recipes/999999/recipe_ingredients",
             params: {
               ingredient_id: @bitters.id,
               amount: 2,
               measurement_unit: "dashes"
             }

        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 when the ingredient does not exist" do
        log_in(@user)

        post "/api/v1/recipes/#{@recipe.id}/recipe_ingredients",
             params: {
               ingredient_id: 999999,
               amount: 2,
               measurement_unit: "dashes"
             }

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "PATCH /api/v1/recipe_ingredients/:id" do
      it "does not allow an unauthenticated user to update a recipe ingredient" do
        patch "/api/v1/recipe_ingredients/#{@recipe_ingredient.id}",
              params: {
                amount: 3
              }

        expect(response).to have_http_status(:unauthorized)
        expect(@recipe_ingredient.reload.amount).to eq(2)
      end

      it "does not allow another user to update the recipe ingredient" do
        log_in(@other_user)

        patch "/api/v1/recipe_ingredients/#{@recipe_ingredient.id}",
              params: {
                amount: 3
              }

        expect(response).to have_http_status(:forbidden)
        expect(@recipe_ingredient.reload.amount).to eq(2)
      end

      it "returns 404 when the recipe ingredient does not exist" do
        log_in(@user)

        patch "/api/v1/recipe_ingredients/999999",
              params: {
                amount: 3
              }

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "DELETE /api/v1/recipe_ingredients/:id" do
      it "does not allow an unauthenticated user to delete a recipe ingredient" do
        expect {
          delete "/api/v1/recipe_ingredients/#{@recipe_ingredient.id}"
        }.not_to change(RecipeIngredient, :count)

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow another user to delete the recipe ingredient" do
        log_in(@other_user)

        expect {
          delete "/api/v1/recipe_ingredients/#{@recipe_ingredient.id}"
        }.not_to change(RecipeIngredient, :count)

        expect(response).to have_http_status(:forbidden)
      end

      it "returns 404 when the recipe ingredient does not exist" do
        log_in(@user)

        delete "/api/v1/recipe_ingredients/999999"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
