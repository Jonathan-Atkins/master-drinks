class CreateUserDrinks < ActiveRecord::Migration[8.1]
  def change
    create_table :user_drinks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :drink, null: false, foreign_key: true
      t.boolean :favorite
      t.text :notes

      t.timestamps
    end

    add_index :user_drinks, [ :user_id, :drink_id ], unique: true
  end
end
