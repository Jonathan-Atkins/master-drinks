require "rails_helper"

RSpec.describe "Api::V1::Account", type: :request do
  let(:user) do
    create(
      :user,
      username: "account_user",
      email: "account@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  def login(user)
    post "/api/v1/login",
         params: {
           email: user.email,
           password: "password"
         }
  end

  describe "DELETE /api/v1/account" do
    context "happy path" do
      it "deletes the authenticated user's account" do
        login(user)

        expect do
          delete "/api/v1/account",
                 params: {
                   confirmation: "DELETE"
                 }
        end.to change(User, :count).by(-1)

        expect(response)
          .to have_http_status(:no_content)
      end

      it "deletes the user's drinks and recipes" do
        drink = create(
          :drink,
          user: user
        )

        recipe = create(
          :recipe,
          drink: drink
        )

        login(user)

        delete "/api/v1/account",
               params: {
                 confirmation: "DELETE"
               }

        expect(
          Drink.exists?(drink.id)
        ).to be(false)

        expect(
          Recipe.exists?(recipe.id)
        ).to be(false)
      end

      it "deletes the user's ingredients and recipe ingredients" do
        ingredient = create(
          :ingredient,
          user: user
        )

        drink = create(
          :drink,
          user: user
        )

        recipe = create(
          :recipe,
          drink: drink
        )

        recipe_ingredient = create(
          :recipe_ingredient,
          ingredient: ingredient,
          recipe: recipe
        )

        login(user)

        delete "/api/v1/account",
               params: {
                 confirmation: "DELETE"
               }

        expect(
          Ingredient.exists?(ingredient.id)
        ).to be(false)

        expect(
          RecipeIngredient.exists?(
            recipe_ingredient.id
          )
        ).to be(false)
      end

      it "deletes saved recipe relationships belonging to the user" do
        owner = create(
          :user,
          username: "recipe_owner",
          email: "owner@example.com",
          password: "password",
          password_confirmation: "password"
        )

        drink = create(
          :drink,
          user: owner
        )

        recipe = create(
          :recipe,
          drink: drink
        )

        saved_recipe = create(
          :user_recipe,
          user: user,
          recipe: recipe
        )

        login(user)

        delete "/api/v1/account",
               params: {
                 confirmation: "DELETE"
               }

        expect(
          UserRecipe.exists?(
            saved_recipe.id
          )
        ).to be(false)
      end

      it "clears the deleted user's session" do
        login(user)

        delete "/api/v1/account",
               params: {
                 confirmation: "DELETE"
               }

        get "/api/v1/session"

        expect(response)
          .to have_http_status(:unauthorized)
      end
    end

    context "sad path" do
      it "does not delete an account without authentication" do
        user

        expect do
          delete "/api/v1/account",
                 params: {
                   confirmation: "DELETE"
                 }
        end.not_to change(User, :count)

        expect(response)
          .to have_http_status(:unauthorized)
      end

      it "does not delete the account without the required confirmation" do
        login(user)

        expect do
          delete "/api/v1/account",
                 params: {
                   confirmation: "delete"
                 }
        end.not_to change(User, :count)

        expect(response)
          .to have_http_status(
            :unprocessable_content
          )
      end

      it "returns an error when confirmation is incorrect" do
        login(user)

        delete "/api/v1/account",
               params: {
                 confirmation: "delete"
               }

        result =
          JSON.parse(response.body)

        expect(
          result["errors"]
        ).to include(
          "Confirmation must be DELETE"
        )
      end
    end
  end
end
