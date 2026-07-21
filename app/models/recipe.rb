class Recipe < ApplicationRecord
  belongs_to :drink

  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients

  validates :name, presence: true

  scope :publicly_visible, -> { where(publicly_visible: true) }

  def self.by_drink_id(drink_id)
    Drink.find(drink_id).recipes
  end

  def self.by_drink_name(drink_name)
    joins(:drink)
      .where("drinks.name ILIKE ?", "%#{drink_name}%")
  end

  def self.search(params)
    if params[:drink_name].present?
      by_drink_name(params[:drink_name])
    else
      all
    end
  end
end
