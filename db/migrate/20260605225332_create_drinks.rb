class CreateDrinks < ActiveRecord::Migration[8.1]
  def change
    create_table :drinks do |t|
      t.string :name, null: false
      t.string :category
      t.boolean :alcoholic, default: true, null: false

      t.timestamps
    end
  end
end
