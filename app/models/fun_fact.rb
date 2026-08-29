class FunFact < ApplicationRecord
  validates :body, presence: true
  validates :source_name, presence: true
  validates :source_url, presence: true
  validates :category, presence: true
end