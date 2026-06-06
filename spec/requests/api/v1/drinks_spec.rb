require "rails_helper"

RSpec.describe "Drinks App", type: :request do
  describe "GET /api/v1/drinks" do
    before(:each) do
      @mojito = Drink.create!(name: "Mojito", category: "Rum", alcoholic: true)
      @old_fashioned = Drink.create!(name: "Old Fashioned", category: "Whiskey", alcoholic: true)
    end

    describe "happy path" do
      it "returns a 200 status code" do
        get "/api/v1/drinks"

        expect(response).to have_http_status(:ok)
      end

      it "returns all drinks" do
        get "/api/v1/drinks"

        drinks = JSON.parse(response.body)

        expect(drinks.count).to eq(2)

        expect(drinks.first["name"]).to eq("Mojito")
        expect(drinks.first["category"]).to eq("Rum")
        expect(drinks.first["alcoholic"]).to eq(true)

        expect(drinks.second["name"]).to eq("Old Fashioned")
        expect(drinks.second["category"]).to eq("Whiskey")
        expect(drinks.second["alcoholic"]).to eq(true)
      end
    end
  end

  describe "POST /api/v1/drinks" do
    describe "happy path" do
      it "can add a drink to the drink menu" do
        post "/api/v1/drinks", params: {
          name: "Margarita",
          category: "Tequila",
          alcoholic: true
        }

        drink = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(Drink.all.count).to eq(1)
        expect(drink["name"]).to eq("Margarita")
        expect(drink["category"]).to eq("Tequila")
        expect(drink["alcoholic"]).to eq(true)
      end
    end
  end
end