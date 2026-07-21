require "rails_helper"

RSpec.describe "My Drinks API", type: :request do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @other_user = User.create!(
      name: "Bob",
      username: "bob",
      email: "bob@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @drink = @user.drinks.create!(
      name: "Old Fashioned",
      category: "whiskey",
      alcoholic: true
    )

    @other_drink = @other_user.drinks.create!(
      name: "Margarita",
      category: "tequila",
      alcoholic: true
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
      email: user.email,
      password: user.password
    }
  end

  describe "happy path" do
    describe "GET /api/v1/my_drinks" do
      it "returns drinks owned by the logged-in user" do
        log_in(@user)

        get "/api/v1/my_drinks"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result).to be_an(Array)
        expect(result.count).to eq(1)
        expect(result.first["id"]).to eq(@drink.id)
        expect(result.first["name"]).to eq("Old Fashioned")
        expect(result.first["category"]).to eq("whiskey")
        expect(result.first["alcoholic"]).to be(true)
      end

      it "does not return drinks owned by another user" do
        log_in(@user)

        get "/api/v1/my_drinks"

        result = JSON.parse(response.body)
        drink_ids = result.pluck("id")

        expect(response).to have_http_status(:ok)
        expect(drink_ids).to include(@drink.id)
        expect(drink_ids).not_to include(@other_drink.id)
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/my_drinks" do
      it "returns an empty array when the logged-in user owns no drinks" do
        @drink.destroy!

        log_in(@user)

        get "/api/v1/my_drinks"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result).to eq([])
      end

      it "returns unauthorized when the user is not logged in" do
        get "/api/v1/my_drinks"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(result["errors"]).to include("You must be logged in")
      end
    end
  end
end
