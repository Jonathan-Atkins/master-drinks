require "rails_helper"

RSpec.describe "Drinks App", type: :request do
  def create_user(attributes = {})
    User.create!(
      {
        name: "Alice",
        username: "AliceInWonderLand",
        email: "alice@email.com",
        password: "12345",
        password_confirmation: "12345",
      }.merge(attributes)
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
      email: user.email,
      password: "12345",
    }
  end

  def create_drink(user, attributes = {})
    category_names = attributes.delete(:category_names) { ["Rum"] }

    categories = category_names.map do |name|
      Category.find_or_create_by!(name: name)
    end

    drink = user.drinks.new(
      {
        name: "Mojito",
        alcoholic: true,
      }.merge(attributes)
    )

    drink.categories = categories
    drink.save!

    drink
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
            category_names: ["Whiskey"],
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
          expect(drinks.first["categories"]).to eq([
            {
              "name" => "Rum",
              "slug" => "rum",
            },
          ])
          expect(drinks.first["alcoholic"]).to eq(true)

          expect(drinks.second["name"]).to eq("Old Fashioned")
          expect(drinks.second["categories"]).to eq([
            {
              "name" => "Whiskey",
              "slug" => "whiskey",
            },
          ])
          expect(drinks.second["alcoholic"]).to eq(true)
        end
      end

      describe "sorting" do
        before(:each) do
          @user = create_user

          @daiquiri = create_drink(
            @user,
            name: "Daiquiri",
            category_names: ["Rum"],
          )

          @margarita = create_drink(
            @user,
            name: "Margarita",
            category_names: ["Tequila"],
          )

          @old_fashioned = create_drink(
            @user,
            name: "Old Fashioned",
            category_names: ["Whiskey"],
          )
        end

        it "returns drinks in alphabetical order by name" do
          get "/api/v1/drinks?sort=name"

          drinks = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)

          expect(drinks.map { |drink| drink["name"] }).to eq([
            "Daiquiri",
            "Margarita",
            "Old Fashioned",
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
            "Daiquiri",
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
            "Daiquiri",
          ])
        end
      end

      it "returns only publicly visible drinks" do
        user = create_user

        public_drink = create_drink(
          user,
          name: "Old Fashioned",
          category_names: ["Whiskey"],
          publicly_visible: true,
        )

        private_drink = create_drink(
          user,
          name: "Private Margarita",
          category_names: ["Tequila"],
          publicly_visible: false,
        )

        get "/api/v1/drinks"

        result = JSON.parse(response.body)
        drink_ids = result.pluck("id")

        expect(response).to have_http_status(:ok)
        expect(drink_ids).to include(public_drink.id)
        expect(drink_ids).not_to include(private_drink.id)
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
        expect(drink["categories"]).to eq([
          {
            "name" => "Rum",
            "slug" => "rum",
          },
        ])
      end
    end

    describe "POST /api/v1/drinks" do
      it "can add a drink to the drink menu" do
        user = create_user

        log_in(user)

        Category.find_or_create_by!(name: "Tequila")

        post "/api/v1/drinks", params: {
          category_slugs: ["tequila"],
          name: "Margarita",
          alcoholic: true,
        }

        drink = JSON.parse(response.body)
        created_drink = Drink.last

        expect(response).to have_http_status(:created)
        expect(drink["name"]).to eq("Margarita")
        expect(drink["categories"]).to eq([
          {
            "name" => "Tequila",
            "slug" => "tequila",
          },
        ])
        expect(drink["alcoholic"]).to eq(true)
        expect(created_drink.user_id).to eq(user.id)
      end

      it "can create a drink with multiple categories" do
        user = create_user

        log_in(user)

        Category.find_or_create_by!(name: "Vodka")
        Category.find_or_create_by!(name: "Gin")
        Category.find_or_create_by!(name: "Rum")
        Category.find_or_create_by!(name: "Tequila")

        post "/api/v1/drinks", params: {
          name: "Long Island Iced Tea",
          category_slugs: [
            "vodka",
            "gin",
            "rum",
            "tequila",
          ],
          alcoholic: true,
        }

        drink = Drink.last

        expect(response).to have_http_status(:created)

        expect(drink.categories.pluck(:name)).to contain_exactly(
          "Vodka",
          "Gin",
          "Rum",
          "Tequila"
        )
      end
    end

    describe "PATCH /api/v1/drinks/:id" do
      before(:each) do
        @user = create_user
        @drink = create_drink(@user)
      end

      it "can update a drink owned by the logged-in user" do
        Category.find_or_create_by!(name: "White Rum")

        log_in(@user)

        patch "/api/v1/drinks/#{@drink.id}", params: {
          category_slugs: ["white-rum"],
          name: "Mojito Rio",
        }

        drink = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(drink["name"]).to eq("Mojito Rio")
        expect(drink["categories"]).to eq([
          {
            "name" => "White Rum",
            "slug" => "white-rum",
          },
        ])
      end

      it "allows the owner to make their drink private" do
        log_in(@user)

        patch "/api/v1/drinks/#{@drink.id}",
              params: { publicly_visible: false }

        result = JSON.parse(response.body)

        @drink.reload

        expect(response).to have_http_status(:ok)
        expect(@drink.publicly_visible).to be(false)
        expect(result["publicly_visible"]).to be(false)
      end

      it "allows the owner to make their drink public again" do
        @drink.update!(publicly_visible: false)

        log_in(@user)

        patch "/api/v1/drinks/#{@drink.id}",
              params: { publicly_visible: true }

        result = JSON.parse(response.body)

        @drink.reload

        expect(response).to have_http_status(:ok)
        expect(@drink.publicly_visible).to be(true)
        expect(result["publicly_visible"]).to be(true)
      end
    end

    describe "DELETE /api/v1/drinks/:id" do
      it "can delete a drink owned by the logged-in user" do
        user = create_user

        drink = create_drink(
          user,
          name: "Rum & Coke",
        )

        log_in(user)

        delete "/api/v1/drinks/#{drink.id}"

        expect(response).to have_http_status(:no_content)
        expect(Drink.exists?(drink.id)).to eq(false)
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
        Category.find_or_create_by!(name: "Tequila")

        post "/api/v1/drinks", params: {
          category_slugs: ["tequila"],
          name: "Margarita",
          alcoholic: true,
        }

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(result["errors"]).to include("You must be logged in")
      end

      it "returns unauthorized when updating a drink without being logged in" do
        user = create_user
        drink = create_drink(user)

        patch "/api/v1/drinks/#{drink.id}", params: {
          name: "Updated Drink",
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
          email: "bob@email.com",
        )

        @drink = create_drink(@owner)

        log_in(@other_user)
      end

      it "does not allow a user to update another user's drink" do
        patch "/api/v1/drinks/#{@drink.id}", params: {
          name: "Changed Drink",
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

      it "does not allow a user to view another user's private drink" do
        user1 = create_user(
          name: "Jon",
          username: "JonInWonderLand",
          email: "jon@email.com",
        )

        user2 = create_user

        private_drink = create_drink(
          user1,
          name: "Salty Dog",
          category_names: ["Vodka"],
          alcoholic: true,
          publicly_visible: false,
        )

        log_in(user2)

        get "/api/v1/drinks/#{private_drink.id}"

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)

        expect(error["errors"]).to include(
          "Couldn't find Drink with 'id'=\"#{private_drink.id}\""
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
        Category.find_or_create_by!(name: "Tequila")

        post "/api/v1/drinks", params: {
          category_slugs: ["tequila"],
          name: nil,
          alcoholic: true,
        }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message if the drink is not created" do
        Category.find_or_create_by!(name: "Tequila")

        post "/api/v1/drinks", params: {
          category_slugs: ["tequila"],
          name: nil,
          alcoholic: true,
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Name can't be blank")
      end

      it "returns an error message for duplicate drink names" do
        Category.find_or_create_by!(name: "Tequila")

        post "/api/v1/drinks", params: {
          category_slugs: ["tequila"],
          name: "Mojito",
          alcoholic: true,
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Name has already been taken")
      end

      it "returns an error message for invalid category slug" do
        post "/api/v1/drinks", params: {
          name: "Milkshake",
          category_slugs: ["milkshake"],
          alcoholic: true,
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)

        expect(error["errors"]).to include(
          "Categories must include at least one category"
        )
      end
    end

    describe "PATCH /api/v1/drinks/:id" do
      before(:each) do
        @user = create_user

        @mojito = create_drink(@user)

        Category.find_or_create_by!(name: "White Rum")

        @old_fashioned = create_drink(
          @user,
          name: "Old Fashioned",
          category_names: ["Whiskey"],
        )

        log_in(@user)
      end

      it "returns a 404 if the drink does not exist" do
        patch "/api/v1/drinks/999", params: {
          category_slugs: ["white-rum"],
          name: "Mojito Rio",
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)

        expect(error["errors"]).to include(
          "Couldn't find Drink with 'id'=\"999\""
        )
      end

      it "returns a 422 if the update has invalid attributes" do
        patch "/api/v1/drinks/#{@mojito.id}", params: {
          category_slugs: ["white-rum"],
          name: nil,
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Name can't be blank")
      end

      it "returns an error if the updated name is already taken" do
        patch "/api/v1/drinks/#{@mojito.id}", params: {
          category_slugs: ["rum"],
          name: "Old Fashioned",
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error["errors"]).to include("Name has already been taken")
      end

      it "returns an error if the updated category slug is invalid" do
        patch "/api/v1/drinks/#{@mojito.id}", params: {
          category_slugs: ["milkshake"],
          name: "Mojito Rio",
        }

        error = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)

        expect(error["errors"]).to include(
          "Categories must include at least one category"
        )
      end

      it "does not allow another user to change drink visibility" do
        other_user = create_user(
          name: "Bob",
          username: "BobTheBartender",
          email: "bob@email.com",
        )

        log_in(other_user)

        patch "/api/v1/drinks/#{@mojito.id}",
              params: { publicly_visible: false }

        @mojito.reload

        expect(response).to have_http_status(:forbidden)
        expect(@mojito.publicly_visible).to be(true)
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