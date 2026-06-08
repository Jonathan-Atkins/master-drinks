require "rails_helper"

RSpec.describe "Drinks App", type: :request do
  before(:each) do
      @mojito = Drink.create!(name: "Mojito", category: "Rum", alcoholic: true)
      @old_fashioned = Drink.create!(name: "Old Fashioned", category: "Whiskey", alcoholic: true)
  end

  describe "happy path" do
    describe "GET api/v1/drinks" do
      it "returns a 200 status code" do
        get "/api/v1/drinks"

        expect(response).to have_http_status(:ok)
      end

      it "returns all drinks" do
        get "/api/v1/drinks"

        drinks = JSON.parse(response.body)

        expect(drinks.count).to eq(2)

        expect(drinks.first["name"]).to eq("Mojito")
        expect(drinks.first["category"]).to eq("rum")
        expect(drinks.first["alcoholic"]).to eq(true)

        expect(drinks.second["name"]).to eq("Old Fashioned")
        expect(drinks.second["category"]).to eq("whiskey")
        expect(drinks.second["alcoholic"]).to eq(true)
      end
    end
    
    describe "GET api/v1/drinks/:id" do
      it "returns one drink" do
        get "/api/v1/drinks/#{@mojito.id}"

        drink = JSON.parse(response.body)
        expect(drink["id"]).to eq(@mojito["id"])
        expect(drink["name"]).to eq(@mojito["name"])
      end
    end
    describe "POST api/v1/drinks" do
      it "can add a drink to the drink menu" do
        post "/api/v1/drinks", params: {
          name: "Margarita",
          category: "Tequila",
          alcoholic: true
        }

        drink = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(drink["name"]).to eq("Margarita")
        expect(drink["category"]).to eq("tequila")
        expect(drink["alcoholic"]).to eq(true)
      end
    end
  end

  describe "sad path" do
    describe "POST" do
      it "returns a 422 status code if the drink is not created" do
        post "/api/v1/drinks", params: {
          name: nil,
          category: "Tequila",
          alcoholic: true
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message if the drink is not created" do
        post "/api/v1/drinks", params: {
          name: nil,
          category: "Tequila",
          alcoholic: true
        }
        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(error["errors"]).to include("Name can't be blank")
      end

      it "returns an error message for duplicated drink names" do
        post "/api/v1/drinks", params: {
          name: "Mojito",
          category: "Tequila",
          alcoholic: true
        }
        
        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(error["errors"]).to include("Name has already been taken")
      end

      it "returns an error message for invalid category type" do
        drink = Drink.new(name: "BTS", category: "milkshake", alcoholic: true)

        post "/api/v1/drinks", params: {
          name: "Milkshake",
          category: "Milkshake",
          alcoholic: true
        }

        error = JSON.parse(response.body)
        expect(error["errors"]).to include("Category is not included in the list")
      end
    end
  end
end