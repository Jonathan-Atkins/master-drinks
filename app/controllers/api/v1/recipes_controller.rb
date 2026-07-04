class Api::V1::RecipesController < ApplicationController
  before_action :set_drink, only: [ :create ]
  before_action :set_recipe, only: [ :show, :update, :destroy ]
  before_action :authorize_drink_owner, only: [ :create ]
  before_action :authorize_recipe_owner, only: [ :update, :destroy ]

  def index
    recipes =
      if params[:drink_id]
        Drink.find(params[:drink_id]).recipes
      else
        Recipe.all
      end

    render json: RecipeSerializer.format_collection(recipes), status: :ok
  end

  def show
    render json: RecipeSerializer.format(@recipe), status: :ok
  end

  def create
    recipe = @drink.recipes.new(recipe_params)

    if recipe.save
      render json: RecipeSerializer.format(recipe), status: :created
    else
      render json: ErrorSerializer.format(recipe), status: :unprocessable_content
    end
  end

  def update
    if @recipe.update(recipe_params)
      render json: RecipeSerializer.format(@recipe), status: :ok
    else
      render json: ErrorSerializer.format(@recipe), status: :unprocessable_content
    end
  end

  def destroy
    @recipe.destroy

    head :no_content
  end

  private

  def recipe_params
    params.permit(:name, :instructions)
  end

  def set_drink
    @drink = Drink.find(params[:drink_id])
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])

    return unless params[:drink_id]
    return if @recipe.drink_id == params[:drink_id].to_i

    raise ActiveRecord::RecordNotFound,
          "Couldn't find Recipe with id=#{params[:id]} for Drink with id=#{params[:drink_id]}"
  end

  def authorize_drink_owner
    return if @drink.user_id == current_user.id

    render json: {
      errors: [ "You are not authorized to modify this recipe" ]
    }, status: :forbidden
  end

  def authorize_recipe_owner
    return if @recipe.drink.user_id == current_user.id

    render json: {
      errors: [ "You are not authorized to modify this recipe" ]
    }, status: :forbidden
  end
end
