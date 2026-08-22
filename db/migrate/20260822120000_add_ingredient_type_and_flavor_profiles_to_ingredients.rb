class AddIngredientTypeAndFlavorProfilesToIngredients < ActiveRecord::Migration[8.1]
  def change
    add_column :ingredients, :ingredient_type, :string, null: false, default: "Other"
    add_column :ingredients, :flavor_profiles, :string, array: true, null: false, default: []
  end
end
