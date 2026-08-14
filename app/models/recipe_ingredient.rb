class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  validates :amount, presence: true
  validates :measurement_unit, presence: true
end
