class Drink < ApplicationRecord
  belongs_to :user

  has_many :recipes, dependent: :destroy

  scope :publicly_visible, -> { where(publicly_visible: true) }

  enum :category, {
    vodka: "vodka",
    gin: "gin",
    rum: "rum",
    white_rum: "white_rum",
    cachaca: "cachaca",
    tequila: "tequila",
    mezcal: "mezcal",
    whiskey: "whiskey",
    bourbon: "bourbon",
    rye: "rye",
    scotch: "scotch",
    irish_whiskey: "irish_whiskey",
    brandy: "brandy",
    cognac: "cognac",
    armagnac: "armagnac",
    calvados: "calvados",
    pisco: "pisco",
    soju: "soju",
    shochu: "shochu",
    sake: "sake",
    baijiu: "baijiu",
    liqueur: "liqueur",
    amaro: "amaro",
    aperitif: "aperitif",
    vermouth: "vermouth",
    fortified_wine: "fortified_wine",
    wine: "wine",
    champagne: "champagne",
    beer: "beer",
    cider: "cider",
    aquavit: "aquavit",
    genever: "genever",
    ouzo: "ouzo",
    raki: "raki",
    arak: "arak",
    absinthe: "absinthe",
    non_alcoholic: "non_alcoholic"
  }, validate: true

  before_validation :normalize_name
  before_validation :normalize_category

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :category, presence: true
  validates :alcoholic, inclusion: { in: [true, false] }

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

  def normalize_name
    self.name = name&.squish
  end

  def normalize_category
    self.category = category&.strip&.downcase&.tr(" ", "_")
  end
end