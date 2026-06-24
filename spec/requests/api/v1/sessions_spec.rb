require "rails_helper"

RSpec.describe "Sessions API", type: :request do
  describe "happy path" do
    describe "POST /api/v1/login" do
      it "logs in a user with valid credentials" do
        user = User.create!(
          name: "Alice",
          username: "AliceInWonderLand",
          email: "alice@email.com",
          password: "12345",
          password_confirmation: "12345"
        )

        login_params = {
          email: user.email,
          password: "12345"
        }

        post "/api/v1/login", params: login_params

        result = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(result["user"]["id"]).to eq(user.id)
        expect(result["user"]["email"]).to eq(user.email)
        expect(result["user"]).not_to have_key("password_digest")
      end
    end
  end

  describe "sad path" do
    describe "POST /api/v1/login" do
      it "returns an error when the password does not match" do
        user = User.create!(
          name: "Alice",
          username: "AliceInWonderLand",
          email: "alice@email.com",
          password: "12345",
          password_confirmation: "12345"
        )

        login_params = {
          email: user.email,
          password: "wrong-password"
        }

        post "/api/v1/login", params: login_params
        result = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(result["errors"]).to include("Invalid email or password")
      end
    end
  end
end