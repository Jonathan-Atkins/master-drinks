class FunFact < ApplicationRecord
  validates :body, presence: true
  validates :drink_name, presence: true
end
