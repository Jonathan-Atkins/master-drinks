class Api::V1::IngredientsController < ApplicationController
  skip_before_action :require_login, only: [ :index, :show ]

  before_action :set_ingredient, only: [ :show, :update, :destroy ]

  def index
    ingredients = Ingredient.all

    render json: ingredients, status: :ok
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

  def update
    if @ingredient.update(ingredient_params)
      render json: @ingredient, status: :ok
    else
      render json: ErrorSerializer.format(@ingredient),
             status: :unprocessable_content
    end
  end

  def destroy
    @ingredient.destroy

    head :no_content
  end

  private

  def ingredient_params
    params.permit(:name)
  end

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end
end
