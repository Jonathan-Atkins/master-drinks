class Api::V1::MyDrinksController < ApplicationController
  def index
    drinks = current_user.drinks

    render json: DrinkSerializer.format_collection(drinks), status: :ok
end

