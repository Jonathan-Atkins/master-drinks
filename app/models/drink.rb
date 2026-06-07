class Drink < ApplicationRecord
  enum :category, {
    vodka: "vodka",
    gin: "gin",
    rum: "rum",
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

  before_validation :normalize_category

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
  validates :alcoholic, inclusion: { in: [true, false] }

  private

  def normalize_category
    self.category = category&.downcase
  end
end