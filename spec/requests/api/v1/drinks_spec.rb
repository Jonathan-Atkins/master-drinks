require "rails_helper"

RSpec.describe "Drinks App", type: :request do
  def create_user(attributes = {})
    User.create!(
      {
        name: "Alice",
        username: "AliceInWonderLand",
        email: "alice@email.com",
        password: "12345",
        password_confirmation: "12345"
      }.merge(attributes)
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
      email: user.email,
      password: "12345"
    }
  end

  def create_drink(user, attributes = {})
    user.drinks.create!(
      {
        name: "Mojito",
        category: "rum",
        alcoholic: true
      }.merge(attributes)
    )
  end

  describe "happy path" do
    describe "GET /api/v1/drinks" do
      describe "basic index response" do
        before(:each) do
          @user = create_user

          @mojito = create_drink(@user)

          @old_fashioned = create_drink(
            @user,
            name: "Old Fashioned",
            category: "whiskey"
          )
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
          @user = create_user

          @daiquiri = create_drink(
            @user,
            name: "Daiquiri",
            category: "rum"
          )

          @margarita = create_drink(
            @user,
            name: "Margarita",
            category: "tequila"
          )

          @old_fashioned = create_drink(
            @user,
            name: "Old Fashioned",
            category: "whiskey"
          )
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
      it "returns one drink" do
        user = create_user
        mojito = create_drink(user)
        log_in(user)

        get "/api/v1/drinks/#{mojito.id}"

        drink = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drink["id"]).to eq(mojito.id)
        expect(drink["name"]).to eq(mojito.name)
      end
    end

    describe "POST /api/v1/drinks" do
      it "can add a drink to the drink menu" do
        user = create_user
        log_in(user)

        post "/api/v1/drinks", params: {
          name: "Margarita",
          category: "Tequila",
          alcoholic: true
        }

        drink = JSON.parse(response.body)
        created_drink = Drink.last

        expect(response).to have_http_status(:created)
        expect(drink["name"]).to eq("Margarita")
        expect(drink["category"]).to eq("tequila")
        expect(drink["alcoholic"]).to eq(true)
        expect(created_drink.user_id).to eq(user.id)
      end
    end

    describe "PATCH /api/v1/drinks/:id" do
      it "can update a drink owned by the logged-in user" do
        user = create_user
        mojito = create_drink(user)
        log_in(user)

        patch "/api/v1/drinks/#{mojito.id}", params: {
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
      it "can delete a drink owned by the logged-in user" do
        user = create_user

        drink = create_drink(
          user,
          name: "Rum & Coke"
        )

        log_in(user)

        delete "/api/v1/drinks/#{drink.id}"

        expect(response).to have_http_status(:no_content)
        expect(Drink.exists?(drink.id)).to eq(false)
      end
    end
  end

  describe "authentication" do
    it "allows anyone to view all drinks" do
      get "/api/v1/drinks"

      expect(response).to have_http_status(:ok)
    end

    it "returns unauthorized when showing a drink without being logged in" do
      user = create_user
      drink = create_drink(user)

      get "/api/v1/drinks/#{drink.id}"

      result = JSON.parse(response.body)

      expect(response).to have_http_status(:unauthorized)
      expect(result["errors"]).to include("You must be logged in")
    end

    it "returns unauthorized when creating a drink without being logged in" do
      post "/api/v1/drinks", params: {
        name: "Margarita",
        category: "tequila",
        alcoholic: true
      }

      result = JSON.parse(response.body)

      expect(response).to have_http_status(:unauthorized)
      expect(result["errors"]).to include("You must be logged in")
    end

    it "returns unauthorized when updating a drink without being logged in" do
      user = create_user
      drink = create_drink(user)

      patch "/api/v1/drinks/#{drink.id}", params: {
        name: "Updated Drink"
      }

      result = JSON.parse(response.body)

      expect(response).to have_http_status(:unauthorized)
      expect(result["errors"]).to include("You must be logged in")
    end

    it "returns unauthorized when deleting a drink without being logged in" do
      user = create_user
      drink = create_drink(user)

      expect do
        delete "/api/v1/drinks/#{drink.id}"
      end.not_to change(Drink, :count)

      result = JSON.parse(response.body)

      expect(response).to have_http_status(:unauthorized)
      expect(result["errors"]).to include("You must be logged in")
    end
  end

  describe "authorization" do
    before(:each) do
      @owner = create_user

      @other_user = create_user(
        name: "Bob",
        username: "BobTheBartender",
        email: "bob@email.com"
      )

      @drink = create_drink(@owner)

      log_in(@other_user)
    end

    it "does not allow a user to update another user's drink" do
      patch "/api/v1/drinks/#{@drink.id}", params: {
        name: "Changed Drink"
      }

      result = JSON.parse(response.body)
      @drink.reload

      expect(response).to have_http_status(:forbidden)
      expect(result["errors"]).to include(
        "You are not authorized to modify this drink"
      )
      expect(@drink.name).to eq("Mojito")
    end

    it "does not allow a user to delete another user's drink" do
      expect do
        delete "/api/v1/drinks/#{@drink.id}"
      end.not_to change(Drink, :count)

      result = JSON.parse(response.body)

      expect(response).to have_http_status(:forbidden)
      expect(result["errors"]).to include(
        "You are not authorized to modify this drink"
      )
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
        user = create_user
        log_in(user)

        get "/api/v1/drinks/999"

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(error["errors"]).to include(
          "Couldn't find Drink with 'id'=\"999\""
        )
      end
    end

    describe "POST /api/v1/drinks" do
      before(:each) do
        @user = create_user
        @mojito = create_drink(@user)
        log_in(@user)
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
        expect(error["errors"]).to include(
          "Category is not included in the list"
        )
      end
    end

    describe "PATCH /api/v1/drinks/:id" do
      before(:each) do
        @user = create_user
        @mojito = create_drink(@user)

        @old_fashioned = create_drink(
          @user,
          name: "Old Fashioned",
          category: "whiskey"
        )

        log_in(@user)
      end

      it "returns a 404 if the drink does not exist" do
        patch "/api/v1/drinks/999", params: {
          name: "Mojito Rio",
          category: "white_rum"
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(error["errors"]).to include(
          "Couldn't find Drink with 'id'=\"999\""
        )
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
        expect(error["errors"]).to include(
          "Category is not included in the list"
        )
      end
    end

    describe "DELETE /api/v1/drinks/:id" do
      it "returns a 404 if the drink does not exist" do
        user = create_user
        log_in(user)

        delete "/api/v1/drinks/999"

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(error["errors"]).to include(
          "Couldn't find Drink with 'id'=\"999\""
        )
      end
    end
  end
end
