require "rails_helper"

RSpec.describe "Categories API", type: :request do
  describe "happy path" do
    describe "GET /api/v1/categories" do
      it "returns all categories with their ingredient metadata" do
        vodka = create_category(
          "Spec Vodka",
          alcoholic: true
        )

        gin = create_category(
          "Spec Gin",
          alcoholic: true
        )

        get "/api/v1/categories"

        categories =
          JSON.parse(response.body)

        expect(response).to have_http_status(:ok)

        expect(categories).to include(
          {
            "id" => vodka.id,
            "name" => "Spec Vodka",
            "slug" => "spec-vodka",
            "alcoholic" => true,
            "ingredient" => {
              "id" => vodka.ingredient.id,
              "name" => "Spec Vodka"
            }
          },
          {
            "id" => gin.id,
            "name" => "Spec Gin",
            "slug" => "spec-gin",
            "alcoholic" => true,
            "ingredient" => {
              "id" => gin.ingredient.id,
              "name" => "Spec Gin"
            }
          }
        )
      end

      it "returns only alcoholic categories when alcoholic is true" do
        alcoholic_category =
          create_category(
            "Spec Bourbon",
            alcoholic: true
          )

        nonalcoholic_category =
          create_category(
            "Spec Nonalcoholic Spirit",
            alcoholic: false
          )

        get "/api/v1/categories",
            params: {
              alcoholic: true
            }

        categories =
          JSON.parse(response.body)

        category_ids =
          categories.pluck("id")

        expect(response).to have_http_status(:ok)

        expect(category_ids).to include(
          alcoholic_category.id
        )

        expect(category_ids).not_to include(
          nonalcoholic_category.id
        )
      end

      it "returns only nonalcoholic categories when alcoholic is false" do
        alcoholic_category =
          create_category(
            "Spec Gin",
            alcoholic: true
          )

        nonalcoholic_category =
          create_category(
            "Spec Nonalcoholic Gin",
            alcoholic: false
          )

        get "/api/v1/categories",
            params: {
              alcoholic: false
            }

        categories =
          JSON.parse(response.body)

        category_ids =
          categories.pluck("id")

        expect(response).to have_http_status(:ok)

        expect(category_ids).to include(
          nonalcoholic_category.id
        )

        expect(category_ids).not_to include(
          alcoholic_category.id
        )
      end
    end
  end
end
