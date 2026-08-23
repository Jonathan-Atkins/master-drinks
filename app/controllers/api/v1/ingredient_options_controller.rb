class Api::V1::IngredientOptionsController < ApplicationController
  skip_before_action :require_login,
                     only: [ :index ]

  def index
    render json: {
      ingredient_types:
        Ingredient::INGREDIENT_TYPES,
      flavor_profiles:
        Ingredient::FLAVOR_PROFILES
    },
           status: :ok
  end
end
