class Api::V1::SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :create, :destroy ]

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      render json: {
        user: UserSerializer.created(user)
      }, status: :ok
    else
      render json: {
        errors: [ "Invalid email or password" ]
      }, status: :unauthorized
    end
  end

  def destroy
    if session[:user_id]
      session.delete(:user_id)

      render json: {
        message: "Logged out successfully"
      }, status: :ok
    else
      render json: {
        errors: [ "No active session" ]
      }, status: :unauthorized
    end
  end
end
