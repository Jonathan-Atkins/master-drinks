class AddPubliclyVisibleToDrinks < ActiveRecord::Migration[8.1]
  def change
    add_column :drinks,
           :publicly_visible,
           :boolean,
           default: true,
           null: false
  end
end
