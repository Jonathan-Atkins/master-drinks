class Api::V1::Profiles::DrinksController < ApplicationController
  PER_PAGE = 10

  def index
    user = User.find_by!(
      username: params[:profile_username]
    )

    drinks =
      user
        .drinks
        .publicly_visible
        .includes(
          :categories,
          :recipes
        )
        .order(
          created_at: :desc
        )

    page = [
      params.fetch(:page, 1).to_i,
      1
    ].max

    total_count = drinks.count

    total_pages =
      (
        total_count.to_f /
        PER_PAGE
      ).ceil

    paginated_drinks =
      drinks
        .limit(PER_PAGE)
        .offset(
          (page - 1) * PER_PAGE
        )

    render json: {
      drinks:
        DrinkSerializer.format_collection(
          paginated_drinks
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