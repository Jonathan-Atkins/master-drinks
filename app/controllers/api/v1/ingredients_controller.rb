class Api::V1::IngredientsController < ApplicationController
  skip_before_action :require_login, only: [:index]

  def index
    ingredients = Ingredient.all

    render json: ingredients
  end
end