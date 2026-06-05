class Api::V1::DrinksController < ApplicationController
  def index
    drinks = Drink.all
    render json: drinks, status: :ok
  end
end