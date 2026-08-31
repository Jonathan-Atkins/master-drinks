class AddDrinkNameToFunFacts < ActiveRecord::Migration[8.1]
  def change
    add_column :fun_facts, :drink_name, :string

    add_index :fun_facts, :drink_name
  end
end
