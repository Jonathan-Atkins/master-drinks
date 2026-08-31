class Ingredient < ApplicationRecord
  INGREDIENT_TYPES = [
    "Spirit",
    "Liqueur",
    "Wine",
    "Beer",
    "Bitters",
    "Syrup",
    "Citrus",
    "Juice",
    "Mixer",
    "Dairy",
    "Sweetener",
    "Herb",
    "Spice",
    "Garnish",
    "Other"
  ].freeze

  FLAVOR_PROFILES = [
    "Sweet",
    "Sour",
    "Bitter",
    "Herbal",
    "Floral",
    "Tropical",
    "Spicy",
    "Smoky",
    "Fruity",
    "Creamy",
    "Savory",
    "Citrusy",
    "Dry",
    "Rich"
  ].freeze

  belongs_to :user, optional: true

  has_many :recipe_ingredients,
           dependent: :destroy

  has_many :recipes,
           through: :recipe_ingredients

  validates :name,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }

  validates :ingredient_type,
            inclusion: {
              in: INGREDIENT_TYPES
            }

  validate :flavor_profiles_must_be_valid

  def flavor_profiles
    super || []
  end

  private

  def flavor_profiles_must_be_valid
    invalid_flavor_profiles = flavor_profiles - FLAVOR_PROFILES

    return if invalid_flavor_profiles.empty?

    errors.add(
      :flavor_profiles,
      "contains invalid values: #{invalid_flavor_profiles.join(", ")}"
    )
  end
end
