class Api::V1::CategoriesController <
  ApplicationController
  skip_before_action(
    :require_login,
    only: [ :index ]
  )

  def index
    categories =
      Category
        .includes(:ingredient)
        .order(:name)

    if params.key?(:alcoholic)
      alcoholic =
        ActiveModel::Type::Boolean
          .new
          .cast(
            params[:alcoholic]
          )

      categories =
        categories.where(
          alcoholic: alcoholic
        )
    end

    render json:
      categories.map {
        |category|
        format_category(category)
      },
      status: :ok
  end

  private

  def format_category(category)
    {
      id: category.id,
      name: category.name,
      slug: category.slug,
      alcoholic:
        category.alcoholic,
      ingredient: {
        id:
          category.ingredient.id,
        name:
          category.ingredient.name
      }
    }
  end
end
