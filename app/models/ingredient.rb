class Ingredient < ApplicationRecord
  belongs_to :user

  has_many :recipe_ingredients
  has_many :recipes, through: :recipe_ingredients

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }
end
