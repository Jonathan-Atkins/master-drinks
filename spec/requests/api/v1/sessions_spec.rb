require "rails_helper"

RSpec.describe "Sessions API", type: :request do
  before(:each) do
    @user = User.create!(
          name: "Alice",
          username: "AliceInWonderLand",
          email: "alice@email.com",
          password: "12345",
          password_confirmation: "12345"
        )
    @login_params = {
          email: @user.email,
          password: @user.password
        }
  end
  describe "happy path" do
    describe "POST /api/v1/login" do
      it "logs in a user with valid credentials" do

        post "/api/v1/login", params: @login_params

        result = JSON.parse(response.body)
        
        expect(response).to have_http_status(:ok)
        expect(result["user"]["id"]).to eq(@user.id)
        expect(result["user"]["email"]).to eq(@user.email)
        expect(result["user"]).not_to have_key("password_digest")
      end
    end
    describe "DELETE /api/v1/login" do
      it "logs out a user" do

        post "/api/v1/login", params: @login_params
        expect(session[:user_id]).to eq(@user.id)

        delete "/api/v1/logout"
        expect(response).to have_http_status(:ok)
        expect(session[:user_id]).to be_nil
      end
    end
  end
  describe "sad path" do
    describe "POST /api/v1/login" do
      it "returns an error when the password does not match" do
        login_params = {
          email: @user.email,
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