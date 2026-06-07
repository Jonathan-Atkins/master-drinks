class Drink < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
  validates :alcoholic, inclusion: { in: [true, false] }
end