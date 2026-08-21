require "rails_helper"

RSpec.describe "Account", type: :request do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
      email: user.email,
      password: "password123"
    }
  end

  describe "DELETE /api/v1/account" do
    describe "happy path" do
      it "deletes the logged-in user's account" do
        log_in(@user)

        expect do
          delete "/api/v1/account",
                 params: { confirmation: "DELETE" }
        end.to change(User, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end

      it "deletes the user's drinks and recipes" do
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
          instructions: "Stir with ice."
        )

        log_in(@user)

        delete "/api/v1/account",
               params: { confirmation: "DELETE" }

        expect(Drink.exists?(drink.id)).to be(false)
        expect(Recipe.exists?(recipe.id)).to be(false)
      end

      it "deletes the user's ingredients and recipe ingredients" do
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
          instructions: "Stir with ice."
        )

        ingredient = Ingredient.create!(
          user: @user,
          name: "Bourbon"
        )

        recipe_ingredient = RecipeIngredient.create!(
          recipe: recipe,
          ingredient: ingredient,
          amount: 2,
          measurement_unit: "oz"
        )

        log_in(@user)

        delete "/api/v1/account",
               params: { confirmation: "DELETE" }

        expect(
          RecipeIngredient.exists?(recipe_ingredient.id)
        ).to be(false)

        expect(
          Ingredient.exists?(ingredient.id)
        ).to be(false)
      end

      it "deletes saved recipe relationships" do
        other_user = User.create!(
          name: "Bob",
          username: "bob",
          email: "bob@example.com",
          password: "password123",
          password_confirmation: "password123"
        )

        drink = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [ "Tequila" ]
        )

        recipe = Recipe.create!(
          drink: drink,
          name: "Classic Margarita",
          instructions: "Shake with ice."
        )

        saved_recipe = UserRecipe.create!(
          user: other_user,
          recipe: recipe
        )

        log_in(@user)

        delete "/api/v1/account",
               params: { confirmation: "DELETE" }

        expect(
          UserRecipe.exists?(saved_recipe.id)
        ).to be(false)

        expect(User.exists?(other_user.id)).to be(true)
      end

      it "clears the deleted user's session" do
        log_in(@user)

        delete "/api/v1/account",
               params: { confirmation: "DELETE" }

        get "/api/v1/session"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "sad path" do
      it "does not delete an account without authentication" do
        expect do
          delete "/api/v1/account",
                 params: { confirmation: "DELETE" }
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not delete the account without the DELETE confirmation" do
        log_in(@user)

        expect do
          delete "/api/v1/account",
                 params: { confirmation: "delete" }
        end.not_to change(User, :count)

        result = JSON.parse(response.body)

        expect(response).to have_http_status(
          :unprocessable_content
        )

        expect(result["errors"]).to include(
          "Type DELETE to confirm account deletion"
        )
      end
    end
  end
end