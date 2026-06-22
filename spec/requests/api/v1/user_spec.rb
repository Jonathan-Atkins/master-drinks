require "rails_helper"

RSpec.describe "User App", type: :request do
  describe "happy path" do
    before(:each) do
          @user_params = {
            name: "Alice", 
            username: "AliceInWonderLand",
            email: "alice@email.com",
            password: "12345",
            password_confirmation: "12345"
          }
        end
    describe "POST /api/v1/users" do
      it "can create a user" do
        post "/api/v1/users", params: @user_params

        result = JSON.parse(response.body)
        expect(result["name"]).to eq("Alice")
      end
    end 
  end
end