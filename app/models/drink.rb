class Drink < ApplicationRecord
  belongs_to :user

  has_many :recipes, dependent: :destroy

  scope :publicly_visible, -> { where(publicly_visible: true) }

  enum :category, {
    Vodka: "Vodka",
    Gin: "Gin",
    Rum: "Rum",
    White_Rum: "White_Rum",
    Cachaca: "Cachaca",
    Tequila: "Tequila",
    Mezcal: "Mezcal",
    Whiskey: "Whiskey",
    Bourbon: "Bourbon",
    Rye: "Rye",
    Scotch: "Scotch",
    Irish_Whiskey: "Irish_Whiskey",
    Brandy: "Brandy",
    Cognac: "Cognac",
    Armagnac: "Armagnac",
    Calvados: "Calvados",
    Pisco: "Pisco",
    Soju: "Soju",
    Shochu: "Shochu",
    Sake: "Sake",
    Baijiu: "Baijiu",
    Liqueur: "Liqueur",
    Amaro: "Amaro",
    Aperitif: "Aperitif",
    Vermouth: "Vermouth",
    Fortified_Wine: "Fortified_Wine",
    Wine: "Wine",
    Champagne: "Champagne",
    Beer: "Beer",
    Cider: "Cider",
    Aquavit: "Aquavit",
    Genever: "Genever",
    Ouzo: "Ouzo",
    Raki: "Raki",
    Arak: "Arak",
    Absinthe: "Absinthe",
    Non_Alcoholic: "Non_Alcoholic"
  }, validate: true

  before_validation :normalize_name
  before_validation :normalize_category

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }

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

  def normalize_name
    self.name = name&.squish
  end

  def normalize_category
    self.category = category&.strip&.split("_")&.map(&:capitalize)&.join("_")
  end
end
