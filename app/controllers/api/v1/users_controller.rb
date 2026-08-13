class Api::V1::UsersController < ApplicationController
  skip_before_action :require_login, only: [ :create ]

  before_action :set_user, only: [ :show, :update, :destroy, :password ]
  before_action :authorize_user, only: [ :update, :destroy, :password ]

  def index
    users = User.search(params)

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

  def password
    unless @user.authenticate(params[:current_password])
      render json: { errors: ["Current password is incorrect"] },
            status: :unauthorized
      return
    end

    if @user.update(
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
      render json: { message: "Password updated successfully" },
            status: :ok
    else
      render json: ErrorSerializer.format(@user),
            status: :unprocessable_content
    end
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

    def authorize_user
      return if current_user == @user

      render json: ErrorSerializer.forbidden_deletion, status: :forbidden
    end
end
