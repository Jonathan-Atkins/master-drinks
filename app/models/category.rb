class Category < ApplicationRecord
  belongs_to :ingredient

  has_many :drink_categories,
           dependent: :destroy

  has_many :drinks,
           through: :drink_categories

  before_validation :generate_slug

  validates :name,
            presence: true,
            uniqueness: true

  validates :slug,
            presence: true,
            uniqueness: true

  validates :alcoholic,
            inclusion: {
              in: [ true, false ]
            }

  validate :ingredient_must_be_global

  scope :alcoholic,
        -> {
          where(alcoholic: true)
        }

  scope :nonalcoholic,
        -> {
          where(alcoholic: false)
        }

  private

  def generate_slug
    self.slug =
      name.parameterize if name.present?
  end

  def ingredient_must_be_global
    return unless ingredient
    return if ingredient.user_id.nil?

    errors.add(
      :ingredient,
      "must be a global ingredient"
    )
  end
end
