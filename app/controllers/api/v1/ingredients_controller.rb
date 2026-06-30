class Api::V1::IngredientsController < ApplicationController
  skip_before_action :require_login, only: [ :index, :show ]

  def index
    ingredients = Ingredient.all

    render json: ingredients
  end

  def show
    ingredient = Ingredient.find(params[:id])

    render json: ingredient, status: :ok
  end
end
