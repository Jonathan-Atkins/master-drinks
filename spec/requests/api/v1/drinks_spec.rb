require "rails_helper"

RSpec.describe "Drinks App", type: :request do
  describe "happy path" do
    describe "GET /api/v1/drinks" do
      describe "basic index response" do
        before(:each) do
          @mojito = Drink.create!(name: "Mojito", category: "rum", alcoholic: true)
          @old_fashioned = Drink.create!(name: "Old Fashioned", category: "whiskey", alcoholic: true)
        end

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

      describe "sorting" do
        before(:each) do
          @daiquiri = Drink.create!(name: "Daiquiri", category: "rum", alcoholic: true)
          @margarita = Drink.create!(name: "Margarita", category: "tequila", alcoholic: true)
          @old_fashioned = Drink.create!(name: "Old Fashioned", category: "whiskey", alcoholic: true)
        end

        it "returns drinks in alphabetical order by name" do
          get "/api/v1/drinks?sort=name"

          drinks = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(drinks.map { |drink| drink["name"] }).to eq([
            "Daiquiri",
            "Margarita",
            "Old Fashioned"
          ])
        end

        it "returns drinks sorted by category" do
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
          @daiquiri.update_columns(created_at: 3.days.ago)
          @margarita.update_columns(created_at: 2.days.ago)
          @old_fashioned.update_columns(created_at: 1.day.ago)

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
          @daiquiri.update_columns(updated_at: 3.days.ago)
          @margarita.update_columns(updated_at: 2.days.ago)
          @old_fashioned.update_columns(updated_at: 1.day.ago)

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
    end

    describe "GET /api/v1/drinks/:id" do
      before(:each) do
        @mojito = Drink.create!(name: "Mojito", category: "rum", alcoholic: true)
      end

      it "returns one drink" do
        get "/api/v1/drinks/#{@mojito.id}"

        drink = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drink["id"]).to eq(@mojito.id)
        expect(drink["name"]).to eq(@mojito.name)
      end
    end

    describe "POST /api/v1/drinks" do
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
      before(:each) do
        @mojito = Drink.create!(name: "Mojito", category: "rum", alcoholic: true)
      end

      it "can update a drink" do
        patch "/api/v1/drinks/#{@mojito.id}", params: {
          name: "Mojito Rio",
          category: "White Rum"
        }

        drink = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drink["name"]).to eq("Mojito Rio")
        expect(drink["category"]).to eq("white_rum")
      end
    end

    describe "DELETE /api/v1/drinks/:id" do
      before(:each) do
        @drink = Drink.create!(name: "Rum & Coke", category: "rum", alcoholic: true)
      end
      it "can delete a drink" do
        delete "/api/v1/drinks/#{@drink.id}"

        expect(response).to have_http_status(:no_content)
        expect(Drink.exists?(@drink.id)).to eq(false)
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/drinks" do
      it "returns an empty array if there are no drinks" do
        get "/api/v1/drinks"

        drinks = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drinks).to eq([])
      end
    end

    describe "GET /api/v1/drinks/:id" do
      it "returns an error if the drink doesn't exist" do
        get "/api/v1/drinks/999"

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(error["errors"]).to include("Couldn't find Drink with 'id'=\"999\"")
      end
    end

    describe "POST /api/v1/drinks" do
      before(:each) do
        @mojito = Drink.create!(name: "Mojito", category: "rum", alcoholic: true)
      end

      it "returns a 422 status code if the drink is not created" do
        post "/api/v1/drinks", params: {
          name: nil,
          category: "tequila",
          alcoholic: true
        }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message if the drink is not created" do
        post "/api/v1/drinks", params: {
          name: nil,
          category: "tequila",
          alcoholic: true
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Name can't be blank")
      end

      it "returns an error message for duplicate drink names" do
        post "/api/v1/drinks", params: {
          name: "Mojito",
          category: "tequila",
          alcoholic: true
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Name has already been taken")
      end

      it "returns an error message for invalid category type" do
        post "/api/v1/drinks", params: {
          name: "Milkshake",
          category: "Milkshake",
          alcoholic: true
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Category is not included in the list")
      end
    end
    describe "PATCH /api/v1/drinks/:id" do
      before(:each) do
        @mojito = Drink.create!(name: "Mojito", category: "rum", alcoholic: true)
        @old_fashioned = Drink.create!(name: "Old Fashioned", category: "whiskey", alcoholic: true)
      end
      it "returns a 404 if the drink does not exist" do
        patch "/api/v1/drinks/999", params: {
          name: "Mojito Rio",
          category: "white_rum"
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(error["errors"]).to include("Couldn't find Drink with 'id'=\"999\"")
      end
      it "returns a 422 if the update has invalid attributes" do
        patch "/api/v1/drinks/#{@mojito.id}", params: {
          name: nil,
          category: "white_rum"
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Name can't be blank")
      end
      it "returns an error if the updated name is already taken" do
        patch "/api/v1/drinks/#{@mojito.id}", params: {
          name: "Old Fashioned",
          category: "rum"
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Name has already been taken")
      end

      it "returns an error if the updated category is invalid" do
        patch "/api/v1/drinks/#{@mojito.id}", params: {
          name: "Mojito Rio",
          category: "milkshake"
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Category is not included in the list")
      end
    end
    describe "DELETE /api/v1/drinks/:id" do
      it "returns a 404 if object id does not exist" do
        delete "/api/v1/drinks/999"
        
        error = JSON.parse(response.body)
        
        expect(response).to have_http_status(:not_found)
        expect(error["errors"]).to include("Couldn't find Drink with 'id'=\"999\"")
      end

    end
  end
end