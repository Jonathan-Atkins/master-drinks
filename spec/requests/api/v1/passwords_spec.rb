require "rails_helper"

RSpec.describe "Api::V1::Passwords", type: :request do
  let(:user) do
    create(
      :user,
      username: "password_user",
      email: "password@example.com",
      password: "oldpassword",
      password_confirmation: "oldpassword"
    )
  end

  let(:other_user) do
    create(
      :user,
      username: "other_user",
      email: "other@example.com",
      password: "oldpassword",
      password_confirmation: "oldpassword"
    )
  end

  def login(user)
    post "/api/v1/login",
         params: {
           email: user.email,
           password: "oldpassword"
         }
  end

  describe "PATCH /api/v1/users/:user_id/password" do
    context "happy path" do
      it "updates the authenticated user's password" do
        login(user)

        patch "/api/v1/users/#{user.id}/password",
              params: {
                current_password: "oldpassword",
                password: "newpassword",
                password_confirmation: "newpassword"
              }

        expect(response)
          .to have_http_status(:ok)

        user.reload

        expect(
          user.authenticate("newpassword")
        ).to be_truthy
      end

      it "returns a success message" do
        login(user)

        patch "/api/v1/users/#{user.id}/password",
              params: {
                current_password: "oldpassword",
                password: "newpassword",
                password_confirmation: "newpassword"
              }

        result =
          JSON.parse(response.body)

        expect(
          result["message"]
        ).to eq(
          "Password updated successfully"
        )
      end
    end

    context "sad path" do
      it "does not allow an unauthenticated user to change a password" do
        patch "/api/v1/users/#{user.id}/password",
              params: {
                current_password: "oldpassword",
                password: "newpassword",
                password_confirmation: "newpassword"
              }

        expect(response)
          .to have_http_status(:unauthorized)

        user.reload

        expect(
          user.authenticate("oldpassword")
        ).to be_truthy
      end

      it "does not allow a user to change another user's password" do
        login(user)

        patch "/api/v1/users/#{other_user.id}/password",
              params: {
                current_password: "oldpassword",
                password: "newpassword",
                password_confirmation: "newpassword"
              }

        expect(response)
          .to have_http_status(:forbidden)

        other_user.reload

        expect(
          other_user.authenticate("oldpassword")
        ).to be_truthy
      end

      it "does not change the password when the current password is incorrect" do
        login(user)

        patch "/api/v1/users/#{user.id}/password",
              params: {
                current_password: "wrongpassword",
                password: "newpassword",
                password_confirmation: "newpassword"
              }

        expect(response)
          .to have_http_status(:unauthorized)

        user.reload

        expect(
          user.authenticate("oldpassword")
        ).to be_truthy

        expect(
          user.authenticate("newpassword")
        ).to be_falsey
      end

      it "does not change the password when confirmation does not match" do
        login(user)

        patch "/api/v1/users/#{user.id}/password",
              params: {
                current_password: "oldpassword",
                password: "newpassword",
                password_confirmation: "differentpassword"
              }

        expect(response)
          .to have_http_status(
            :unprocessable_content
          )

        user.reload

        expect(
          user.authenticate("oldpassword")
        ).to be_truthy

        expect(
          user.authenticate("newpassword")
        ).to be_falsey
      end
    end
  end
end
