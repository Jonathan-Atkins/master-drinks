require "rails_helper"

RSpec.describe "Ingredient Filters API", type: :request do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @bourbon = Ingredient.create!(
      user: @user,
      name: "Bourbon",
      ingredient_type: "Spirit",
      flavor_profiles: [
        "Rich"
      ]
    )

    @orange_juice = Ingredient.create!(
      user: @user,
      name: "Orange Juice",
      ingredient_type: "Juice",
      flavor_profiles: [
        "Citrusy",
        "Sweet"
      ]
    )

    @simple_syrup = Ingredient.create!(
      user: @user,
      name: "Simple Syrup",
      ingredient_type: "Syrup",
      flavor_profiles: [
        "Sweet"
      ]
    )
  end

  describe "happy path" do
    describe "GET /api/v1/ingredients" do
      it "filters ingredients by ingredient type" do
        get "/api/v1/ingredients",
            params: {
              ingredient_type: "Spirit"
            }

        result = JSON.parse(response.body)

        ingredient_ids =
          result.map do |ingredient|
            ingredient["id"]
          end

        expect(response).to have_http_status(:ok)

        expect(ingredient_ids).to include(
          @bourbon.id
        )

        expect(ingredient_ids).not_to include(
          @orange_juice.id
        )

        expect(ingredient_ids).not_to include(
          @simple_syrup.id
        )
      end

      it "filters ingredients by flavor profile" do
        get "/api/v1/ingredients",
            params: {
              flavor_profile: "Sweet"
            }

        result = JSON.parse(response.body)

        ingredient_ids =
          result.map do |ingredient|
            ingredient["id"]
          end

        expect(response).to have_http_status(:ok)

        expect(ingredient_ids).to include(
          @orange_juice.id
        )

        expect(ingredient_ids).to include(
          @simple_syrup.id
        )

        expect(ingredient_ids).not_to include(
          @bourbon.id
        )
      end

      it "combines ingredient type and flavor profile filters" do
        get "/api/v1/ingredients",
            params: {
              ingredient_type: "Juice",
              flavor_profile: "Sweet"
            }

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)

        expect(result.length).to eq(1)

        expect(
          result.first["id"]
        ).to eq(@orange_juice.id)
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/ingredients" do
      it "returns an empty array when the filters match no ingredients" do
        get "/api/v1/ingredients",
            params: {
              ingredient_type: "Beer",
              flavor_profile: "Smoky"
            }

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result).to eq([])
      end
    end
  end
end
