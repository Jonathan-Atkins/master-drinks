class CreateFunFacts < ActiveRecord::Migration[8.1]
  def change
    create_table :fun_facts do |t|
      t.text :body, null: false
      t.string :source_name, null: false
      t.string :source_url, null: false
      t.string :category, null: false

      t.timestamps
    end

    add_index :fun_facts, :category
  end
end