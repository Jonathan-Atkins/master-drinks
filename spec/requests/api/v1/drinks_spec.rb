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
      it "returns drinks in alphabetical order" do
        Drink.destroy_all

        Drink.create!(name: "Whiskey Sour", category: "whiskey", alcoholic: true)
        Drink.create!(name: "Daiquiri", category: "rum", alcoholic: true)
        Drink.create!(name: "Margarita", category: "tequila", alcoholic: true)

        get "/api/v1/drinks?sort=name"

        drinks = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(drinks.map { |drink| drink["name"] }).to eq([
          "Daiquiri",
          "Margarita",
          "Whiskey Sour"
        ])
      end
      it "returns drinks sorted by category" do
        Drink.destroy_all

        Drink.create!(name: "Old Fashioned", category: "whiskey", alcoholic: true)
        Drink.create!(name: "Margarita", category: "tequila", alcoholic: true)
        Drink.create!(name: "Daiquiri", category: "rum", alcoholic: true)

        get "/api/v1/drinks?sort=category"

        drinks = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drinks.map { |drink| drink["category"] }).to eq([
          "rum",
          "tequila",
          "whiskey"
        ])
      end
      it "returns drinks sorted by date added with newest first" do
        Drink.destroy_all

        daiquiri = Drink.create!(name: "Daiquiri", category: "rum", alcoholic: true)
        margarita = Drink.create!(name: "Margarita", category: "tequila", alcoholic: true)
        old_fashioned = Drink.create!(name: "Old Fashioned", category: "whiskey", alcoholic: true)

        daiquiri.update_columns(created_at: 3.days.ago)
        margarita.update_columns(created_at: 2.days.ago)
        old_fashioned.update_columns(created_at: 1.day.ago)

        get "/api/v1/drinks?sort=date_added"

        drinks = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drinks.map { |drink| drink["name"] }).to eq([
          "Old Fashioned",
          "Margarita",
          "Daiquiri"
        ])
      end
      
      it "returns drinks sorted by date edited with most recently edited first" do
        Drink.destroy_all

        daiquiri = Drink.create!(name: "Daiquiri", category: "rum", alcoholic: true)
        margarita = Drink.create!(name: "Margarita", category: "tequila", alcoholic: true)
        old_fashioned = Drink.create!(name: "Old Fashioned", category: "whiskey", alcoholic: true)

        daiquiri.update_columns(updated_at: 3.days.ago)
        margarita.update_columns(updated_at: 2.days.ago)
        old_fashioned.update_columns(updated_at: 1.day.ago)

        get "/api/v1/drinks?sort=date_edited"

        drinks = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drinks.map { |drink| drink["name"] }).to eq([
          "Old Fashioned",
          "Margarita",
          "Daiquiri"
        ])
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
    describe "PATCH /api/v1/drinks/:id" do
      it "can update a drink" do
        patch "/api/v1/drinks/#{@mojito[:id]}", params: {
          name: "Mojito Rio",
          category: "White Rum"
        }

        @mojito = JSON.parse(response.body)

        expect(@mojito["name"]).to eq("Mojito Rio")
        expect(@mojito["category"]).to eq("white_rum")
      end
    end
  end
  describe "sad path" do
    describe "GET /api/v1/drinks" do
      it "returns an empty array if there are no drinks" do
        Drink.destroy_all

        get "/api/v1/drinks"

        drinks = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drinks).to eq([])
      end
    end

    describe "GET /api/v1/drinks/:id" do
      it "returns an error if the drink doesnt exist" do
        get "/api/v1/drinks/999"

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(error["errors"]).to include("Couldn't find Drink with 'id'=\"999\"")
      end
    end

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
    describe "PATCH" do
      
    end
  end
end
