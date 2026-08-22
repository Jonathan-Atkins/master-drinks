class Recipe < ApplicationRecord
  belongs_to :drink

  has_many :recipe_ingredients,
           dependent: :destroy

  has_many :ingredients,
           through: :recipe_ingredients

  has_many :user_recipes,
           dependent: :destroy

  validates :name, presence: true

  scope :publicly_visible,
        -> { where(publicly_visible: true) }

  scope :most_recent,
        -> { order(created_at: :desc) }

  scope :most_saved,
        -> {
          left_joins(:user_recipes)
            .group("recipes.id")
            .order(
              Arel.sql(
                "COUNT(user_recipes.id) DESC"
              )
            )
        }

  def self.by_drink_id(drink_id)
    Drink.find(drink_id).recipes
  end

  def self.by_drink_name(drink_name)
    joins(:drink)
      .where(
        "drinks.name ILIKE ?",
        "%#{drink_name}%"
      )
  end

  def self.search(params)
    if params[:drink_name].present?
      by_drink_name(
        params[:drink_name]
      )
    else
      all
    end
  end

  def self.search_and_filter(params)
    recipes =
      if params[:drink_id].present?
        by_drink_id(
          params[:drink_id]
        )
      else
        search(params)
      end

    recipes.publicly_visible
  end

  def self.sorted_by(sort)
    case sort
    when "recent"
      most_recent
    when "saved"
      most_saved
    else
      all
    end
  end
end