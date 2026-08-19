class CreateDrinkCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :drink_categories do |t|
      t.references :drink, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :drink_categories,
              [:drink_id, :category_id],
              unique: true
  end
end