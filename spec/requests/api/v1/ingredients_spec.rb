require "rails_helper"

RSpec.describe "Api::V1::Ingredients", type: :request do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123",
    )

    @drink = create_drink(
      @user,
      {
        name: "Old Fashioned",
        alcoholic: true
      },
      category_names: [ "Whiskey" ],
    )

    @ingredient = create_ingredient(
      @user,
      {
        name: "Bourbon",
        ingredient_type: "Spirit",
        flavor_profiles: [ "Rich", "Dry" ]
      }
    )
  end

  def create_request_ingredient(user, attributes = {})
    create_ingredient(
      user,
      {
        name: "Bourbon",
        ingredient_type: "Spirit",
        flavor_profiles: [ "Rich" ]
      }.merge(attributes)
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
                       email: user.email,
                       password: "password123"
                     }
  end

  describe "happy path" do
    describe "GET /api/v1/ingredients" do
      it "returns all ingredients without requiring authentication" do
        create_request_ingredient(
          @user,
          name: "Bitters",
          ingredient_type: "Bitters",
          flavor_profiles: [ "Bitter" ],
        )

        get "/api/v1/ingredients"

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result.count).to eq(3)

        expect(result.pluck("name")).to contain_exactly(
          "Whiskey",
          "Bourbon",
          "Bitters"
        )

        bourbon = result.find { |ingredient| ingredient["name"] == "Bourbon" }

        expect(bourbon["ingredient_type"]).to eq("Spirit")
        expect(bourbon["flavor_profiles"]).to contain_exactly("Rich", "Dry")
        expect(bourbon["owned_by_current_user"]).to be(false)
      end

      it "returns ingredients matching the search" do
        create_request_ingredient(
          @user,
          name: "Angostura Bitters",
          ingredient_type: "Bitters",
          flavor_profiles: [ "Bitter" ],
        )

        get "/api/v1/ingredients",
            params: { search: "Bitters" }

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result.first["name"]).to include("Bitters")
      end

      it "returns each ingredient with its recipe count" do
        test_ingredient = create_request_ingredient(
          @user,
          name: "FlipFlop",
          ingredient_type: "Mixer",
          flavor_profiles: [ "Savory" ],
        )

        log_in(@user)

        recipe = Recipe.create!(
          name: "Classic Old Fashioned",
          instructions: "Stir ingredients",
          drink: @drink,
        )

        RecipeIngredient.create!(
          recipe: recipe,
          ingredient: test_ingredient,
          amount: 2,
          measurement_unit: "oz",
        )

        get "/api/v1/ingredients"

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)

        ingredient_response = parsed_response.find do |item|
          item["id"] == test_ingredient.id
        end

        expect(
          ingredient_response["name"]
        ).to eq("FlipFlop")

        expect(ingredient_response["ingredient_type"]).to eq("Mixer")
        expect(ingredient_response["flavor_profiles"]).to eq([ "Savory" ])

        expect(
          ingredient_response["recipe_count"]
        ).to eq(1)
      end
    end

    describe "GET /api/v1/ingredients/:id" do
      it "returns one ingredient without requiring authentication" do
        get "/api/v1/ingredients/#{@ingredient.id}"

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result["id"]).to eq(@ingredient.id)
        expect(result["name"]).to eq("Bourbon")
        expect(result["ingredient_type"]).to eq("Spirit")
        expect(result["flavor_profiles"]).to contain_exactly("Rich", "Dry")
        expect(result["owned_by_current_user"]).to be(false)
      end

      it "marks the ingredient as owned by the logged-in creator" do
        log_in(@user)

        get "/api/v1/ingredients/#{@ingredient.id}"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["owned_by_current_user"]).to be(true)
      end
    end

    describe "POST /api/v1/ingredients" do
      it "allows an authenticated user to create an ingredient" do
        log_in(@user)

        post "/api/v1/ingredients", params: {
                                 name: "Simple Syrup",
                                 ingredient_type: "Syrup",
                                 flavor_profiles: [ "Sweet" ]
                               }

        expect(response).to have_http_status(:created)

        result = JSON.parse(response.body)

        expect(result["name"]).to eq("Simple Syrup")
        expect(result["ingredient_type"]).to eq("Syrup")
        expect(result["flavor_profiles"]).to eq([ "Sweet" ])
        expect(result["owned_by_current_user"]).to be(true)
        expect(Ingredient.last.name).to eq("Simple Syrup")
        expect(Ingredient.last.user).to eq(@user)
      end
    end

    describe "PATCH /api/v1/ingredients/:id" do
      it "allows an authenticated user to update an ingredient" do
        log_in(@user)

        patch "/api/v1/ingredients/#{@ingredient.id}",
              params: {
                name: "Rye Whiskey",
                ingredient_type: "Spirit",
                flavor_profiles: [ "Dry", "Smoky" ]
              }

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result["name"]).to eq("Rye Whiskey")
        expect(result["ingredient_type"]).to eq("Spirit")
        expect(result["flavor_profiles"]).to contain_exactly("Dry", "Smoky")
        expect(@ingredient.reload.name).to eq("Rye Whiskey")
      end

      it "does not allow another user to update the ingredient" do
        other_user = User.create!(
          name: "Bob",
          username: "bob",
          email: "bob@email.com",
          password: "password123",
          password_confirmation: "password123",
        )

        log_in(other_user)

        patch "/api/v1/ingredients/#{@ingredient.id}",
              params: {
                name: "Changed Name",
                ingredient_type: "Spirit",
                flavor_profiles: [ "Sweet" ]
              }

        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "DELETE /api/v1/ingredients/:id" do
      it "allows an authenticated user to delete an ingredient" do
        log_in(@user)

        expect {
          delete "/api/v1/ingredients/#{@ingredient.id}"
        }.to change(Ingredient, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end

      it "does not allow another user to delete the ingredient" do
        other_user = User.create!(
          name: "Bob",
          username: "bob",
          email: "bob@email.com",
          password: "password123",
          password_confirmation: "password123",
        )

        log_in(other_user)

        expect {
          delete "/api/v1/ingredients/#{@ingredient.id}"
        }.not_to change(Ingredient, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/ingredients/:id" do
      it "returns 404 when the ingredient does not exist" do
        get "/api/v1/ingredients/999999"

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "POST /api/v1/ingredients" do
      it "does not allow an unauthenticated user to create an ingredient" do
        post "/api/v1/ingredients", params: {
                                 name: "Simple Syrup",
                                 ingredient_type: "Syrup",
                                 flavor_profiles: [ "Sweet" ]
                               }

        expect(response).to have_http_status(:unauthorized)

        expect(
          Ingredient.find_by(name: "Simple Syrup")
        ).to be_nil
      end

      it "does not create an ingredient with invalid attributes" do
        log_in(@user)

        post "/api/v1/ingredients", params: {
                                 name: nil,
                                 ingredient_type: "Syrup",
                                 flavor_profiles: [ "Sweet" ]
                               }

        expect(
          response
        ).to have_http_status(:unprocessable_content)

        result = JSON.parse(response.body)

        expect(result["errors"]).to include(
          "Name can't be blank"
        )
      end

      it "returns an error for an invalid ingredient type" do
        log_in(@user)

        post "/api/v1/ingredients", params: {
                                 name: "Mystery Syrup",
                                 ingredient_type: "Potion",
                                 flavor_profiles: [ "Sweet" ]
                               }

        expect(response).to have_http_status(:unprocessable_content)

        body = JSON.parse(response.body)

        expect(body["errors"]).to include(
          "Ingredient type is not included in the list"
        )
      end

      it "returns an error for an invalid flavor profile" do
        log_in(@user)

        post "/api/v1/ingredients", params: {
                                 name: "Odd Syrup",
                                 ingredient_type: "Syrup",
                                 flavor_profiles: [ "Sweet", "Alien" ]
                               }

        expect(response).to have_http_status(:unprocessable_content)

        body = JSON.parse(response.body)

        expect(body["errors"]).to include(
          "Flavor profiles contains invalid values: Alien"
        )
      end

      it "returns an error when the ingredient name already exists" do
        create_request_ingredient(
          @user,
          name: "Unique Bourbon",
          ingredient_type: "Spirit",
          flavor_profiles: [ "Rich" ],
        )

        log_in(@user)

        post "/api/v1/ingredients",
             params: {
               name: "unique bourbon",
               ingredient_type: "Spirit",
               flavor_profiles: [ "Rich" ]
             },
             as: :json

        expect(
          response
        ).to have_http_status(:unprocessable_content)

        body = JSON.parse(response.body)

        expect(body["errors"]).to include(
          "Name has already been taken"
        )
      end
    end

    describe "PATCH /api/v1/ingredients/:id" do
      it "does not allow an unauthenticated user to update an ingredient" do
        patch "/api/v1/ingredients/#{@ingredient.id}",
              params: {
                name: "Rye Whiskey",
                ingredient_type: "Spirit",
                flavor_profiles: [ "Dry" ]
              }

        expect(response).to have_http_status(:unauthorized)
        expect(@ingredient.reload.name).to eq("Bourbon")
      end

      it "does not update an ingredient with invalid attributes" do
        log_in(@user)

        patch "/api/v1/ingredients/#{@ingredient.id}",
              params: {
                name: nil,
                ingredient_type: "Spirit",
                flavor_profiles: [ "Dry" ]
              }

        expect(response).to have_http_status(:unprocessable_content)
        expect(@ingredient.reload.name).to eq("Bourbon")
      end

      it "returns an error for an invalid ingredient type on update" do
        log_in(@user)

        patch "/api/v1/ingredients/#{@ingredient.id}",
              params: {
                name: "Bourbon",
                ingredient_type: "Potion",
                flavor_profiles: [ "Rich" ]
              }

        expect(response).to have_http_status(:unprocessable_content)

        body = JSON.parse(response.body)

        expect(body["errors"]).to include(
          "Ingredient type is not included in the list"
        )
      end

      it "returns an error for an invalid flavor profile on update" do
        log_in(@user)

        patch "/api/v1/ingredients/#{@ingredient.id}",
              params: {
                name: "Bourbon",
                ingredient_type: "Spirit",
                flavor_profiles: [ "Rich", "Alien" ]
              }

        expect(response).to have_http_status(:unprocessable_content)

        body = JSON.parse(response.body)

        expect(body["errors"]).to include(
          "Flavor profiles contains invalid values: Alien"
        )
      end

      it "does not allow another user to update the ingredient" do
        other_user = User.create!(
          name: "Bob",
          username: "bob",
          email: "bob@email.com",
          password: "password123",
          password_confirmation: "password123",
        )

        log_in(other_user)

        patch "/api/v1/ingredients/#{@ingredient.id}",
              params: {
                name: "Changed Name",
                ingredient_type: "Spirit",
                flavor_profiles: [ "Sweet" ]
              }

        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "DELETE /api/v1/ingredients/:id" do
      it "does not allow an unauthenticated user to delete an ingredient" do
        expect {
          delete "/api/v1/ingredients/#{@ingredient.id}"
        }.not_to change(Ingredient, :count)

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not allow another user to delete the ingredient" do
        other_user = User.create!(
          name: "Bob",
          username: "bob",
          email: "bob@email.com",
          password: "password123",
          password_confirmation: "password123",
        )

        log_in(other_user)

        expect {
          delete "/api/v1/ingredients/#{@ingredient.id}"
        }.not_to change(Ingredient, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
