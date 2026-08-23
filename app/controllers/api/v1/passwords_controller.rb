class Api::V1::PasswordsController < ApplicationController
  before_action :set_user
  before_action :authorize_user

  def update
    unless @user.authenticate(
      params[:current_password]
    )
      render json: {
        errors: [
          "Current password is incorrect",
        ],
      },
             status: :unauthorized

      return
    end

    if @user.update(
      password: params[:password],
      password_confirmation:
        params[:password_confirmation]
    )
      render json: {
        message:
          "Password updated successfully",
      },
             status: :ok
    else
      render json: ErrorSerializer.format(@user),
             status: :unprocessable_content
    end
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end

    def authorize_user
      return if current_user == @user

      render json:
               ErrorSerializer.forbidden_deletion,
             status: :forbidden
    end
end