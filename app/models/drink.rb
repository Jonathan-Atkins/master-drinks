class Drink < ApplicationRecord
  belongs_to :user

  has_many :recipes,
           dependent: :destroy

  has_many :drink_categories,
           dependent: :destroy

  has_many :categories,
           through: :drink_categories

  scope :publicly_visible,
        -> {
          where(
            publicly_visible: true
          )
        }

  before_validation :normalize_name

  validates :name,
            presence: true,
            uniqueness: {
              case_sensitive: false,
              scope: :user_id
            }

  validates :alcoholic,
            inclusion: {
              in: [ true, false ]
            }

  validate :must_have_at_least_one_category
  validate :category_slugs_must_exist
  validate :categories_must_match_drink_type

  def category_slugs=(slugs)
    @requested_category_slugs =
      Array(slugs)
        .reject(&:blank?)
        .uniq

    self.categories =
      Category.where(
        slug:
          @requested_category_slugs
      )
  end

  def next_recipe_name
    base_name = name

    existing_names =
      recipes
        .pluck(:name)
        .compact
        .map(&:downcase)

    return base_name unless existing_names.include?(
      base_name.downcase
    )

    number = 2

    loop do
      candidate =
        "#{base_name} (#{number})"

      return candidate unless existing_names.include?(
        candidate.downcase
      )

      number += 1
    end
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
    self.name =
      name&.squish
  end

  def must_have_at_least_one_category
    return if categories.any?

    errors.add(
      :categories,
      "must include at least one category"
    )
  end

  def category_slugs_must_exist
    return unless defined?(
      @requested_category_slugs
    )

    found_slugs =
      categories.map(&:slug)

    missing_slugs =
      @requested_category_slugs -
      found_slugs

    return if missing_slugs.empty?

    errors.add(
      :categories,
      "contain an invalid category"
    )
  end

  def categories_must_match_drink_type
    return if categories.empty?

    invalid_category =
      categories.any? do |category|
        category.alcoholic !=
          alcoholic
      end

    return unless invalid_category

    drink_type =
      alcoholic ?
        "alcoholic" :
        "non-alcoholic"

    errors.add(
      :categories,
      "must be #{drink_type}"
    )
  end
end
