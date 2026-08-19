class Drink < ApplicationRecord
  belongs_to :user

  has_many :recipes, dependent: :destroy
  has_many :drink_categories, dependent: :destroy
  has_many :categories, through: :drink_categories

  scope :publicly_visible, -> { where(publicly_visible: true) }

  before_validation :normalize_name

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :alcoholic, inclusion: { in: [true, false] }

  validate :must_have_at_least_one_category

  def category_slugs=(slugs)
    self.categories = Category.where(slug: Array(slugs))
  end

  def self.sorted_by(sort_param)
    case sort_param
    when "name"
      order(name: :asc)
    when "date_added"
      order(created_at: :desc)
    when "date_edited"
      order(updated_at: :desc)
    else
      all
    end
  end

  private

  def normalize_name
    self.name = name&.squish
  end

  def must_have_at_least_one_category
    if categories.empty?
      errors.add(:categories, "must include at least one category")
    end
  end
end