require "rails_helper"

RSpec.describe "Profiles API", type: :request do
  before(:each) do
    @viewer = User.create!(
      name: "Viewer",
      username: "viewer",
      email: "viewer@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @profile_user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
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
    describe "GET /api/v1/profiles/:username" do
      it "returns a user profile by username" do
        log_in(@viewer)

        get "/api/v1/profiles/alice"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)

        expect(result).to include(
          "id" => @profile_user.id,
          "username" => "alice",
          "drink_count" => 0,
          "recipe_count" => 0
        )
      end

      it "does not expose private account information" do
        log_in(@viewer)

        get "/api/v1/profiles/alice"

        result = JSON.parse(response.body)

        expect(result).not_to have_key("email")
        expect(result).not_to have_key("name")
        expect(result).not_to have_key("password")
        expect(result).not_to have_key("password_digest")
      end

      it "allows a user to view their own profile" do
        log_in(@profile_user)

        get "/api/v1/profiles/alice"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["username"]).to eq("alice")
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/profiles/:username" do
      it "does not allow an unauthenticated user to view a profile" do
        get "/api/v1/profiles/alice"

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns not found when the username does not exist" do
        log_in(@viewer)

        get "/api/v1/profiles/not-a-real-user"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
