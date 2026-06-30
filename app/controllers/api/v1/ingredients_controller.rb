class Api::V1::IngredientsController < ApplicationController
  skip_before_action :require_login, only: [ :index, :show ]

  before_action :set_ingredient, only: [ :show ]

  def index
    ingredients = Ingredient.all

    render json: ingredients
  end

  def show
    render json: @ingredient, status: :ok
  end

  def create
    ingredient = Ingredient.new(ingredient_params)

    if ingredient.save
      render json: ingredient, status: :created
    else
      render json: ErrorSerializer.format(ingredient),
             status: :unprocessable_content
    end
  end

  private
    def ingredient_params
      params.permit(:name)
    end

    def set_ingredient
      @ingredient = Ingredient.find(params[:id])
    end
end
