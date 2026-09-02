class Api::V1::SessionsController < ApplicationController
  skip_before_action :require_login,
                     only: [ :create, :destroy ]

  def create
    identifier =
      params[:identifier].presence ||
      params[:email]

    user =
      User.find_for_login(identifier)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      render json: {
        user: UserSerializer.created(user)
      }, status: :ok
    else
      render json: {
        errors: [
          "Invalid username, email, or password"
        ]
      }, status: :unauthorized
    end
  end

  def show
    render json: {
      user: UserSerializer.created(
        current_user
      )
    }, status: :ok
  end

  def destroy
    if session[:user_id]
      session.delete(:user_id)

      render json: {
        message: "Logged out successfully"
      }, status: :ok
    else
      render json: {
        errors: [
          "No active session"
        ]
      }, status: :unauthorized
    end
  end
end
