class Api::V1::DrinksController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  def index
    drinks = Drink.all
    render json: drinks, status: :ok
  end

  def show
    drink = Drink.find(params[:id])
    
    render json: drink, status: :ok
  end

  def create
    drink = Drink.create(drink_params)

    if drink.save
      render json: drink, status: :created
    else
      render json: ErrorSerializer.format(drink), status: :unprocessable_entity
    end
  end

  def update
    require 'pry-nav'; binding.pry
  end
 private

  def drink_params
    params.permit(:name, :category, :alcoholic)
  end

  def record_not_found(error)
    render json: { errors: [error.message] }, status: :not_found
  end
end