require "rails_helper"

RSpec.describe "Api::V1::IngredientOptions", type: :request do
  describe "GET /api/v1/ingredient_options" do
    context "happy path" do
      it "returns the allowed ingredient types and flavor profiles" do
        get "/api/v1/ingredient_options"

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)

        expect(json["ingredient_types"])
          .to eq(Ingredient::INGREDIENT_TYPES)

        expect(json["flavor_profiles"])
          .to eq(Ingredient::FLAVOR_PROFILES)
      end
    end
  end
end
