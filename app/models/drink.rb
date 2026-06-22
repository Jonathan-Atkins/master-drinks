class Drink < ApplicationRecord
  enum :category, {
    vodka: "vodka",
    gin: "gin",
    rum: "rum",
    white_rum: "white rum",
    tequila: "tequila",
    mezcal: "mezcal",
    whiskey: "whiskey",
    bourbon: "bourbon",
    rye: "rye",
    scotch: "scotch",
    brandy: "brandy",
    cognac: "cognac",
    pisco: "pisco",
    soju: "soju",
    sake: "sake",
    liqueur: "liqueur",
    amaro: "amaro",
    aperitif: "aperitif",
    fortified_wine: "fortified_wine",
    wine: "wine",
    beer: "beer",
    champagne: "champagne",
    absinthe: "absinthe",
    non_spirit: "non_spirit"
  }, validate: true

  has_many :recipes, dependent: :destroy

  before_validation :normalize_category

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
  validates :alcoholic, inclusion: { in: [ true, false ] }

  def self.sorted_by(sort_param)
    case sort_param
    when "name"
      order(name: :asc)
    when "category"
      order(category: :asc)
    when "date_added"
      order(created_at: :desc)
    when "date_edited"
      order(updated_at: :desc)
    else
      all
    end
  end

  private

  def normalize_category
    self.category = category&.downcase
  end
end
