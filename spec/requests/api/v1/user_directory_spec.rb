require "rails_helper"

RSpec.describe "User Directory API", type: :request do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @bob = User.create!(
      name: "Bob",
      username: "bob",
      email: "bob@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def log_in(user)
    post "/api/v1/login",
         params: {
           email: user.email,
           password: "password123"
         }
  end

  describe "happy path" do
    describe "GET /api/v1/users" do
      it "returns a paginated list of users" do
        log_in(@user)

        get "/api/v1/users"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)

        expect(result).to have_key("users")
        expect(result).to have_key("pagination")

        expect(result["users"]).to be_an(Array)

        expect(result["pagination"]).to include(
          "page" => 1,
          "per_page" => 20
        )
      end

      it "returns community-safe user information" do
        log_in(@user)

        get "/api/v1/users"

        result = JSON.parse(response.body)
        user = result["users"].first

        expect(user).to have_key("username")
        expect(user).to have_key("drink_count")
        expect(user).to have_key("recipe_count")

        expect(user).not_to have_key("email")
        expect(user).not_to have_key("name")
        expect(user).not_to have_key("password_digest")
      end

      it "searches users by partial username" do
        log_in(@user)

        get "/api/v1/users",
            params: {
              search: "bo"
            }

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["users"].count).to eq(1)
        expect(result["users"].first["username"]).to eq("bob")
      end

      it "searches usernames without being case sensitive" do
        log_in(@user)

        get "/api/v1/users",
            params: {
              search: "BOB"
            }

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["users"].count).to eq(1)
        expect(result["users"].first["username"]).to eq("bob")
      end

      it "limits the number of users returned per page" do
        25.times do |number|
          User.create!(
            name: "User #{number}",
            username: "community_user_#{number}",
            email: "community_user_#{number}@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        log_in(@user)

        get "/api/v1/users",
            params: {
              page: 1
            }

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["users"].count).to eq(20)
        expect(result["pagination"]["page"]).to eq(1)
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/users" do
      it "does not allow an unauthenticated user to view the directory" do
        get "/api/v1/users"

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an empty users array when no username matches" do
        log_in(@user)

        get "/api/v1/users",
            params: {
              search: "user-does-not-exist"
            }

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["users"]).to eq([])
      end
    end
  end
end
