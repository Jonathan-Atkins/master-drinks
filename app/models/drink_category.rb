class DrinkCategory < ApplicationRecord
  belongs_to :drink
  belongs_to :category
end
