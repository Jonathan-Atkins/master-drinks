class Category < ApplicationRecord
  has_many :drink_categories, dependent: :destroy
  has_many :drinks, through: :drink_categories

  before_validation :generate_slug

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
