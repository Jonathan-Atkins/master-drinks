class AddPubliclyVisibleToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :publicly_visible, :boolean, default: true, null: false
  end
end
