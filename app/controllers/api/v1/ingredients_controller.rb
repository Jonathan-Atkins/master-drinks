class Api::V1::IngredientsController < ApplicationController
  skip_before_action :require_login,
                     only: [ :index, :show ]

  before_action :set_ingredient,
                only: [ :show, :update, :destroy ]

  before_action :authorize_owner!,
                only: [ :update, :destroy ]

  def index
    ingredients = Ingredient.order(:name)

    if params[:search].present?
      ingredients = ingredients.where(
        "name ILIKE ?",
        "%#{params[:search]}%"
      )
    end

    if params[:ingredient_type].present?
      ingredients = ingredients.where(
        ingredient_type: params[:ingredient_type]
      )
    end

    if params[:flavor_profile].present?
      ingredients = ingredients.where(
        "? = ANY(flavor_profiles)",
        params[:flavor_profile]
      )
    end

    render json: IngredientSerializer.format_collection(
             ingredients,
             current_user
           ),
           status: :ok
  end

  def show
    render json: IngredientSerializer.format(
             @ingredient,
             current_user
           ),
           status: :ok
  end

  def create
    ingredient =
      current_user.ingredients.new(
        ingredient_params
      )

    if ingredient.save
      render json: IngredientSerializer.format(
               ingredient,
               current_user
             ),
             status: :created
    else
      render json: ErrorSerializer.format(
               ingredient
             ),
             status: :unprocessable_content
    end
  end

  def update
    if @ingredient.update(
      ingredient_params
    )
      render json: IngredientSerializer.format(
               @ingredient,
               current_user
             ),
             status: :ok
    else
      render json: ErrorSerializer.format(
               @ingredient
             ),
             status: :unprocessable_content
    end
  end

  def destroy
    @ingredient.destroy

    head :no_content
  end

  private

  def ingredient_params
    params.permit(
      :name,
      :ingredient_type,
      flavor_profiles: [],
    )
  end

  def set_ingredient
    @ingredient =
      Ingredient.find(
        params[:id]
      )
  end

  def authorize_owner!
    return if @ingredient.user_id ==
              current_user.id

    render json: {
             error: "Not authorized"
           },
           status: :forbidden
  end
end
