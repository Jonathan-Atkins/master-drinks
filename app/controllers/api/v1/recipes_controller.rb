class Api::V1::RecipesController < ApplicationController
  before_action :set_drink, only: [ :create ]
  before_action :set_recipe, only: [ :show, :update, :destroy ]

  before_action :authorize_drink_owner, only: [ :create ]
  before_action :authorize_recipe_owner, only: [ :update, :destroy ]
  before_action :authorize_recipe_view, only: [ :show ]

  def index
    recipes = Recipe
      .search_and_filter(params)
      .sorted_by(params[:sort])
      .includes(
        :user_recipes,
        recipe_ingredients: :ingredient,
        drink: [ :user, :categories ]
      )

    render json: RecipeSerializer.format_collection(
      recipes,
      current_user
    ),
          status: :ok
  end

  def show
    render json: RecipeSerializer.format(
      @recipe,
      current_user
    ),
           status: :ok
  end

  def create
    recipe = @drink.recipes.new(recipe_params)

    if recipe.save
      render json: RecipeSerializer.format(
        recipe,
        current_user
      ),
             status: :created
    else
      render json: ErrorSerializer.format(recipe),
             status: :unprocessable_content
    end
  end

  def update
    if @recipe.update(recipe_params)
      render json: RecipeSerializer.format(
        @recipe,
        current_user
      ),
             status: :ok
    else
      render json: ErrorSerializer.format(@recipe),
             status: :unprocessable_content
    end
  end

  def destroy
    @recipe.destroy

    head :no_content
  end

  private

  def recipe_params
    params.permit(
      :name,
      :instructions,
      :publicly_visible
    )
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

    render json: ErrorSerializer.forbidden_recipe_modification,
           status: :forbidden
  end

  def authorize_recipe_owner
    return if @recipe.drink.user_id == current_user.id

    render json: ErrorSerializer.forbidden_recipe_modification,
           status: :forbidden
  end

  def authorize_recipe_view
    return if @recipe.publicly_visible?
    return if @recipe.drink.user_id == current_user.id

    raise ActiveRecord::RecordNotFound,
          "Couldn't find Recipe with 'id'=\"#{@recipe.id}\""
  end
end