require "rails_helper"

RSpec.describe "Categories API", type: :request do
  describe "happy path" do
    describe "GET /api/v1/categories" do
      it "returns all categories" do
        Category.create!(name: "Spec Vodka")
        Category.create!(name: "Spec Gin")

        get "/api/v1/categories"

        categories = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)

        expect(categories).to include(
          {
            "name" => "Spec Vodka",
            "slug" => "spec-vodka"
          },
          {
            "name" => "Spec Gin",
            "slug" => "spec-gin"
          }
        )
      end

      it "returns category names and slugs" do
        category = Category.create!(
          name: "Spec White Rum"
        )

        get "/api/v1/categories"

        categories = JSON.parse(response.body)

        result = categories.find do |item|
          item["name"] == category.name
        end

        expect(result).to eq(
          {
            "name" => "Spec White Rum",
            "slug" => "spec-white-rum"
          }
        )
      end
    end
  end
end
