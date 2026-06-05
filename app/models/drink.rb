class Drink < ApplicationRecord
  validates :name, presence: true
  validates :category, presence: true
  validates :alcoholic, inclusion: { in: [true, false] }
end