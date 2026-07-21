class Api::V1::MyRecipesController < ApplicationController
  def index
    owned_recipes = current_user.owned_recipes

    render json: owned_recipes, status: :ok
  end
end