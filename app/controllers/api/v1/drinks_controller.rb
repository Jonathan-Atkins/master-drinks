class Api::V1::DrinksController < ApplicationController
  def index
    drinks = Drink.all
    render json: drinks, status: :ok
  end

  def show
    drink = Drink.find(params[:id])
    if drink
      render json: drink, status: :ok
    else
      render json: ErrorSerializer.format(drink), status: :not_found
    end
  end

  def create
    drink = Drink.create(drink_params)

    if drink.save
      render json: drink, status: :created
    else
      render json: ErrorSerializer.format(drink), status: :unprocessable_entity
    end
  end

 private

  def drink_params
    params.permit(:name, :category, :alcoholic)
  end
end