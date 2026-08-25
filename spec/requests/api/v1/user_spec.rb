require "rails_helper"

RSpec.describe "User App", type: :request do
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

    @user_params = {
      name: "Charlie",
      username: "charlie",
      email: "charlie@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  def log_in(user)
    post "/api/v1/login",
         params: {
           email: user.email,
           password: "password123"
         }
  end

  describe "happy path" do
    describe "GET /api/v1/users/:id" do
      it "can get one user" do
        user = User.create!(@user_params)

        log_in(user)

        get "/api/v1/users/#{user.id}"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(result["id"]).to eq(user.id)
        expect(result["name"]).to eq("Charlie")
        expect(result["username"]).to eq("charlie")
        expect(result["email"]).to eq("charlie@example.com")
      end
    end

    describe "POST /api/v1/users" do
      it "can create a user" do
        expect do
          post "/api/v1/users",
               params: @user_params
        end.to change(User, :count).by(1)

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(result["name"]).to eq("Charlie")
        expect(result["username"]).to eq("charlie")
        expect(result["email"]).to eq("charlie@example.com")
        expect(result).not_to have_key("password")
        expect(result).not_to have_key("password_confirmation")
        expect(result).not_to have_key("password_digest")
      end
    end

    describe "PATCH /api/v1/users/:id" do
      it "can update a user" do
        user = User.create!(@user_params)

        log_in(user)

        updated_params = {
          name: "Alice Smith",
          username: "AliceInWonderLand"
        }

        patch "/api/v1/users/#{user.id}",
              params: updated_params

        result = JSON.parse(response.body)

        user.reload

        expect(response).to have_http_status(:ok)
        expect(result["name"]).to eq("Alice Smith")
        expect(user.name).to eq("Alice Smith")
        expect(user.username).to eq("AliceInWonderLand")
      end
    end

    describe "PATCH /api/v1/users/:id/password" do
      it "allows a user to change their password" do
        log_in(@user)

        patch "/api/v1/users/#{@user.id}/password",
              params: {
                current_password: "password123",
                password: "newpassword123",
                password_confirmation: "newpassword123"
              }

        expect(response).to have_http_status(:ok)

        @user.reload

        expect(
          @user.authenticate("newpassword123")
        ).to eq(@user)

        expect(
          @user.authenticate("password123")
        ).to be_falsey
      end
    end

    describe "DELETE /api/v1/users/:id" do
      it "can delete a user" do
        user = User.create!(@user_params)

        log_in(user)

        expect do
          delete "/api/v1/users/#{user.id}"
        end.to change(User, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    describe "authorization" do
      before(:each) do
        @logged_in_user = User.create!(@user_params)

        @unauthorized_user = User.create!(
          name: "Dave",
          username: "DaveTheBartender",
          email: "dave@email.com",
          password: "12345",
          password_confirmation: "12345"
        )

        log_in(@logged_in_user)
      end

      it "does not allow a user to update another user's account" do
        patch "/api/v1/users/#{@unauthorized_user.id}",
              params: {
                name: "Updated Name"
              }

        result = JSON.parse(response.body)

        @unauthorized_user.reload

        expect(response).to have_http_status(:forbidden)

        expect(result["errors"]).to include(
          "You are not authorized to delete this user"
        )

        expect(@unauthorized_user.name).to eq("Dave")
      end

      it "does not allow a user to delete another user's account" do
        expect do
          delete "/api/v1/users/#{@unauthorized_user.id}"
        end.not_to change(User, :count)

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:forbidden)

        expect(result["errors"]).to include(
          "You are not authorized to delete this user"
        )
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/users/:id" do
      it "returns an error if the user cannot be found" do
        user = User.create!(@user_params)

        log_in(user)

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
        invalid_user_params =
          @user_params.merge(
            name: nil
          )

        expect do
          post "/api/v1/users",
               params: invalid_user_params
        end.not_to change(User, :count)

        result = JSON.parse(response.body)

        expect(response).to have_http_status(
          :unprocessable_content
        )

        expect(result["errors"]).to include(
          "Name can't be blank"
        )
      end

      it "returns an error if the password confirmation does not match" do
        invalid_user_params =
          @user_params.merge(
            password_confirmation: "wrong-password"
          )

        expect do
          post "/api/v1/users",
               params: invalid_user_params
        end.not_to change(User, :count)

        result = JSON.parse(response.body)

        expect(response).to have_http_status(
          :unprocessable_content
        )

        expect(result["errors"]).to include(
          "Password confirmation doesn't match Password"
        )
      end
    end

    describe "PATCH /api/v1/users/:id" do
      it "returns an error if the user cannot be found" do
        user = User.create!(@user_params)

        log_in(user)

        patch "/api/v1/users/999",
              params: {
                name: "Updated Name"
              }

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)

        expect(result["errors"]).to include(
          "Couldn't find User with 'id'=\"999\""
        )
      end

      it "returns an error if the updated user is invalid" do
        user = User.create!(@user_params)

        log_in(user)

        patch "/api/v1/users/#{user.id}",
              params: {
                name: nil
              }

        result = JSON.parse(response.body)

        user.reload

        expect(response).to have_http_status(
          :unprocessable_content
        )

        expect(result["errors"]).to include(
          "Name can't be blank"
        )

        expect(user.name).to eq("Charlie")
      end
    end

    describe "PATCH /api/v1/users/:id/password" do
      it "does not change the password if the current password is incorrect" do
        log_in(@user)

        patch "/api/v1/users/#{@user.id}/password",
              params: {
                current_password: "wrongpassword",
                password: "newpassword123",
                password_confirmation: "newpassword123"
              }

        expect(response).to have_http_status(:unauthorized)

        @user.reload

        expect(
          @user.authenticate("password123")
        ).to eq(@user)

        expect(
          @user.authenticate("newpassword123")
        ).to be_falsey
      end

      it "does not change the password when the new password confirmation does not match" do
        log_in(@user)

        patch "/api/v1/users/#{@user.id}/password",
              params: {
                current_password: "password123",
                password: "newpassword123",
                password_confirmation: "differentpassword"
              }

        expect(response).to have_http_status(
          :unprocessable_content
        )

        result = JSON.parse(response.body)

        expect(result["errors"]).to include(
          "Password confirmation doesn't match Password"
        )

        @user.reload

        expect(
          @user.authenticate("password123")
        ).to eq(@user)

        expect(
          @user.authenticate("newpassword123")
        ).to be_falsey
      end
    end

    describe "DELETE /api/v1/users/:id" do
      it "returns an error if the user cannot be found" do
        user = User.create!(@user_params)

        log_in(user)

        delete "/api/v1/users/999"

        result = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)

        expect(result["errors"]).to include(
          "Couldn't find User with 'id'=\"999\""
        )
      end
    end
  end
end
