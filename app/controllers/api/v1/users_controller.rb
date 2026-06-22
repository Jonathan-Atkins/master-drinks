class Api::V1::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: ErrorSerializer.format(user), status: :unprocessable_content
    end
  end

  private 

    def user_params
      params.permit(:name, :username, :email, :password, :password_confirmation)
    end
end