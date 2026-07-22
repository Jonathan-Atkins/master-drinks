class Api::V1::UserRecipesController < ApplicationController
  before_action :require_login, only: [ :index, :create, :destroy ]
  before_action :set_recipe, only: [ :create ]
  before_action :set_user_recipe, only: [ :destroy ]

  def index
    recipes = current_user.recipes.publicly_visible

    render json: RecipeSerializer.format_collection(recipes), status: :ok
  end

  def create
    user_recipe = current_user.user_recipes.new(recipe: @recipe)

    if user_recipe.save
      render json: RecipeSerializer.format(@recipe), status: :created
    else
      render json: ErrorSerializer.format(user_recipe),
             status: :unprocessable_content
    end
  end

  def destroy
    @user_recipe.destroy

    head :no_content
  end

  private

  def valid_params
    params.permit(:recipe_id)
  end

  def set_recipe
    @recipe = Recipe.publicly_visible.find(valid_params[:recipe_id])
  end

  def set_user_recipe
    @user_recipe = current_user.user_recipes.find(params[:id])
  end
end