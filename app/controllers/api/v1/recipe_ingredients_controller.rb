class Api::V1::RecipeIngredientsController < ApplicationController
  before_action :set_recipe, only: [ :create ]
  before_action :set_recipe_ingredient, only: [ :update, :destroy ]

  before_action :authorize_recipe_owner, only: [ :create ]
  before_action :authorize_recipe_ingredient_owner,
                only: [ :update, :destroy ]

  def create
    ingredient = Ingredient.find(recipe_ingredient_params[:ingredient_id])

    recipe_ingredient = @recipe.recipe_ingredients.new(
      ingredient: ingredient,
      amount: recipe_ingredient_params[:amount],
      measurement_unit: recipe_ingredient_params[:measurement_unit]
    )

    if recipe_ingredient.save
      render json: RecipeIngredientSerializer.format(recipe_ingredient),
             status: :created
    else
      render json: ErrorSerializer.format(recipe_ingredient),
             status: :unprocessable_content
    end
  end

  def update
    if @recipe_ingredient.update(update_params)
      render json: RecipeIngredientSerializer.format(@recipe_ingredient),
             status: :ok
    else
      render json: ErrorSerializer.format(@recipe_ingredient),
             status: :unprocessable_content
    end
  end

  def destroy
    @recipe_ingredient.destroy

    head :no_content
  end

  private

  def recipe_ingredient_params
    params.permit(
      :ingredient_id,
      :amount,
      :measurement_unit
    )
  end

  def update_params
    params.permit(
      :amount,
      :measurement_unit
    )
  end

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  def set_recipe_ingredient
    @recipe_ingredient = RecipeIngredient.find(params[:id])
  end

  def authorize_recipe_owner
    return if @recipe.drink.user_id == current_user.id

    render json: {
      errors: [
        "You are not authorized to modify this recipe"
      ]
    }, status: :forbidden
  end

  def authorize_recipe_ingredient_owner
    recipe_owner_id = @recipe_ingredient.recipe.drink.user_id

    return if recipe_owner_id == current_user.id

    render json: {
      errors: [
        "You are not authorized to modify this recipe"
      ]
    }, status: :forbidden
  end
end
