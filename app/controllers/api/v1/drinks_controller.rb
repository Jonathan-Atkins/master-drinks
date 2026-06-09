class Api::V1::DrinksController < ApplicationController
  before_action :set_drink, only: [ :show, :update, :destroy ]

  def index
    drinks = Drink.sorted_by(params[:sort])
    render json: drinks, status: :ok
  end

  def show
    drink = Drink.find(params[:id])

    render json: drink, status: :ok
  end

  def create
    drink = Drink.new(drink_params)

    if drink.save
      render json: drink, status: :created
    else
      render json: ErrorSerializer.format(drink), status: :unprocessable_content
    end
  end

  def update
    drink = Drink.find(params[:id])

    if drink.update(drink_params)
      render json: drink, status: :ok
    else
      render json: ErrorSerializer.format(drink), status: :unprocessable_content
    end
  end

  def destroy
    drink = Drink.find(params[:id])
    drink.destroy

    head :no_content
  end

 private

  def drink_params
    params.permit(:name, :category, :alcoholic)
  end

  def set_drink
    @drink = Drink.find(params[:id])
  end
end
