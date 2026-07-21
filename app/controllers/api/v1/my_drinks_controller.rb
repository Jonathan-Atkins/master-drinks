class Api::V1::MyDrinksController < ApplicationController
  def index
    render json: current_user.drinks
  end
end

