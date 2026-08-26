class Api::V1::Profiles::RecipesController < ApplicationController
  PER_PAGE = 10

  def index
    user = User.find_by!(
      username: params[:profile_username]
    )

    recipes =
      user
        .owned_recipes
        .publicly_visible
        .joins(:drink)
        .where(
          drinks: {
            publicly_visible: true
          }
        )
        .includes(
          :user_recipes,
          drink: [
            :user,
            :categories
          ],
          recipe_ingredients:
            :ingredient
        )
        .order(
          created_at: :desc
        )

    page = [
      params.fetch(:page, 1).to_i,
      1
    ].max

    total_count = recipes.count

    total_pages =
      (
        total_count.to_f /
        PER_PAGE
      ).ceil

    paginated_recipes =
      recipes
        .limit(PER_PAGE)
        .offset(
          (page - 1) * PER_PAGE
        )

    render json: {
      recipes:
        RecipeSerializer.format_collection(
          paginated_recipes,
          current_user
        ),

      pagination: {
        page: page,
        per_page: PER_PAGE,
        total_count: total_count,
        total_pages: total_pages,
        has_previous: page > 1,
        has_next: page < total_pages
      }
    },
           status: :ok
  end
end