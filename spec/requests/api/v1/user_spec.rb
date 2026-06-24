require "rails_helper"

RSpec.describe "User App", type: :request do
  before(:each) do
    @user_params = {
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: "12345",
      password_confirmation: "12345"
    }
  end

  describe "happy path" do
    describe "GET /api/v1/users" do
      it "can get all users" do
        User.create!(@user_params)

        get "/api/v1/users"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result).to be_an(Array)
        expect(result.count).to eq(1)
        expect(result.first["name"]).to eq("Alice")
        expect(result.first["username"]).to eq("AliceInWonderLand")
        expect(result.first["email"]).to eq("alice@email.com")
      end

      it "returns an empty array when no users exist" do
        get "/api/v1/users"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result).to eq([])
      end
    end

    describe "GET /api/v1/users/:id" do
      it "can get one user" do
        user = User.create!(@user_params)

        get "/api/v1/users/#{user.id}"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["id"]).to eq(user.id)
        expect(result["name"]).to eq("Alice")
        expect(result["username"]).to eq("AliceInWonderLand")
        expect(result["email"]).to eq("alice@email.com")
      end
    end

    describe "POST /api/v1/users" do
      it "can create a user" do
        expect do
          post "/api/v1/users", params: @user_params
        end.to change(User, :count).by(1)

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(result["name"]).to eq("Alice")
        expect(result["username"]).to eq("AliceInWonderLand")
        expect(result["email"]).to eq("alice@email.com")
        expect(result).not_to have_key("password")
        expect(result).not_to have_key("password_confirmation")

        # Add this after creating the user serializer:
        # expect(result).not_to have_key("password_digest")
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/users/:id" do
      it "returns an error if the user cannot be found" do
        get "/api/v1/users/999"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(result["errors"]).to include(
          "Couldn't find User with 'id'=\"999\""
        )
      end
    end

    describe "POST /api/v1/users" do
      it "returns an error if the user's name is missing" do
        invalid_user_params = @user_params.merge(name: nil)

        expect do
          post "/api/v1/users", params: invalid_user_params
        end.not_to change(User, :count)

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(result["errors"]).to include("Name can't be blank")
      end

      it "returns an error if the password confirmation does not match" do
        invalid_user_params =
          @user_params.merge(password_confirmation: "wrong-password")

        expect do
          post "/api/v1/users", params: invalid_user_params
        end.not_to change(User, :count)

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_content)
        expect(result["errors"]).to include(
          "Password confirmation doesn't match Password"
        )
      end
    end
  end
end

