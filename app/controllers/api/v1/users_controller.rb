class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [ :show, :update, :destroy ]

  def index
    users = User.all
    render json: UserSerializer.all_users(users), status: :ok
  end

  def show
    render json: UserSerializer.format(@user), status: :ok
  end

  def create
    user = User.new(user_params)

    if user.save
      render json: UserSerializer.format(user), status: :created
    else
      render json: ErrorSerializer.format(user),
             status: :unprocessable_content
    end
  end

  def update
    if @user.update(user_params)
      render json: UserSerializer.format(@user), status: :ok
    else
      render json: ErrorSerializer.format(@user),
             status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy

    head :no_content
  end

  private

  def user_params
    params.permit(
      :name,
      :username,
      :email,
      :password,
      :password_confirmation
    )
  end

  def set_user
    @user = User.find(params[:id])
  end
end
