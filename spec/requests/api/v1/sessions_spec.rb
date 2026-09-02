require "rails_helper"

RSpec.describe "Sessions API",
               type: :request do
  before(:each) do
    @password = "Password123"

    @user = User.create!(
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: @password,
      password_confirmation: @password
    )

    @login_params = {
      identifier: @user.email,
      password: @password
    }
  end

  describe "happy path" do
    describe "POST /api/v1/login" do
      it "logs in a user with their email" do
        post "/api/v1/login",
             params: @login_params

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(:ok)

        expect(
          result["user"]["username"]
        ).to eq(@user.username)

        expect(
          result["user"]["email"]
        ).to eq(@user.email)

        expect(
          result["user"]
        ).not_to have_key(
          "password_digest"
        )
      end

      it "logs in a user with their username" do
        post "/api/v1/login",
             params: {
               identifier:
                 @user.username,
               password:
                 @password
             }

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(:ok)

        expect(
          result["user"]["username"]
        ).to eq(@user.username)
      end

      it "logs in with an email regardless of capitalization" do
        post "/api/v1/login",
             params: {
               identifier:
                 "ALICE@EMAIL.COM",
               password:
                 @password
             }

        expect(response)
          .to have_http_status(:ok)
      end

      it "logs in with a username regardless of capitalization" do
        post "/api/v1/login",
             params: {
               identifier:
                 "aliceinwonderland",
               password:
                 @password
             }

        expect(response)
          .to have_http_status(:ok)
      end

      it "logs in when the identifier has surrounding whitespace" do
        post "/api/v1/login",
             params: {
               identifier:
                 "  #{@user.username}  ",
               password:
                 @password
             }

        expect(response)
          .to have_http_status(:ok)
      end
    end

    describe "DELETE /api/v1/logout" do
      it "logs out a user" do
        post "/api/v1/login",
             params: @login_params

        expect(
          session[:user_id]
        ).to eq(@user.id)

        delete "/api/v1/logout"

        expect(response)
          .to have_http_status(:ok)

        expect(
          session[:user_id]
        ).to be_nil
      end
    end

    describe "GET /api/v1/session" do
      it "returns the current user when logged in" do
        post "/api/v1/login",
             params: @login_params

        get "/api/v1/session"

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(:ok)

        expect(
          result["user"]["username"]
        ).to eq(@user.username)

        expect(
          result["user"]["email"]
        ).to eq(@user.email)

        expect(
          result["user"]
        ).not_to have_key(
          "password_digest"
        )
      end
    end
  end

  describe "sad path" do
    describe "POST /api/v1/login" do
      it "returns an error when the password does not match" do
        post "/api/v1/login",
             params: {
               identifier:
                 @user.email,
               password:
                 "wrong-password"
             }

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(
            :unauthorized
          )

        expect(
          result["errors"]
        ).to include(
          "Invalid username, email, or password"
        )
      end

      it "rejects a password with incorrect capitalization" do
        post "/api/v1/login",
             params: {
               identifier:
                 @user.username,
               password:
                 "password123"
             }

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(
            :unauthorized
          )

        expect(
          result["errors"]
        ).to include(
          "Invalid username, email, or password"
        )
      end

      it "returns an error for an unknown username or email" do
        post "/api/v1/login",
             params: {
               identifier:
                 "unknown-user",
               password:
                 @password
             }

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(
            :unauthorized
          )

        expect(
          result["errors"]
        ).to include(
          "Invalid username, email, or password"
        )
      end

      it "returns an error when the identifier is missing" do
        post "/api/v1/login",
             params: {
               password:
                 @password
             }

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(
            :unauthorized
          )

        expect(
          result["errors"]
        ).to include(
          "Invalid username, email, or password"
        )
      end
    end

    describe "DELETE /api/v1/logout" do
      it "returns an error when no user is logged in" do
        delete "/api/v1/logout"

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(
            :unauthorized
          )

        expect(
          result["errors"]
        ).to include(
          "No active session"
        )
      end
    end

    describe "GET /api/v1/session" do
      it "returns unauthorized when no user is logged in" do
        get "/api/v1/session"

        result =
          JSON.parse(response.body)

        expect(response)
          .to have_http_status(
            :unauthorized
          )

        expect(
          result["errors"]
        ).to include(
          "You must be logged in"
        )
      end
    end
  end
end
