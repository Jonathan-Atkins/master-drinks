class Api::V1::DrinksController < ApplicationController
  skip_before_action :require_login, only: [ :index ]

  before_action :set_drink, only: [ :show, :update, :destroy ]
  before_action :authorize_user, only: [ :update, :destroy ]

  def index
    drinks = Drink.sorted_by(params[:sort])
    render json: drinks, status: :ok
  end

  def show
    render json: @drink, status: :ok
  end

  def create
    drink = current_user.drinks.new(drink_params)

    if drink.save
      render json: drink, status: :created
    else
      render json: ErrorSerializer.format(drink), status: :unprocessable_content
    end
  end

  def update
    if @drink.update(drink_params)
      render json: @drink, status: :ok
    else
      render json: ErrorSerializer.format(@drink), status: :unprocessable_content
    end
  end

  def destroy
    @drink.destroy
    head :no_content
  end

 private

  def drink_params
    params.permit(:name, :category, :alcoholic)
  end

  def set_drink
    @drink = Drink.find(params[:id])
  end

  def authorize_user
    return if @drink.user_id == current_user.id

    render json: ErrorSerializer.forbidden_drink_modification, status: :forbidden
  end
end
