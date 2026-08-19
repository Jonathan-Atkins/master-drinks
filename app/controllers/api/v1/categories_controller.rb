class Api::V1::CategoriesController < ApplicationController
  skip_before_action :require_login, only: [ :index ]

  def index
    categories = Category.order(:name)

    render json: categories.map { |category|
      {
        name: category.name,
        slug: category.slug
      }
    }, status: :ok
  end
end