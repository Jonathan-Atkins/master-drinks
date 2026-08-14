class Api::V1::MyRecipesController < ApplicationController
  def index
    owned_recipes = current_user.owned_recipes
    saved_recipes = current_user.recipes

    recipes = (owned_recipes + saved_recipes).uniq

    render json: RecipeSerializer.format_collection(recipes, current_user),
           status: :ok
  end
end
