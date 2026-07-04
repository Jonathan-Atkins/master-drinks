class UserRecipe < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :recipe, uniqueness: { scope: :user_id }
end
