class RemoveUnusedColumnsFromFunFacts < ActiveRecord::Migration[8.1]
  def change
    remove_column :fun_facts, :source_name, :string
    remove_column :fun_facts, :source_url, :string
    remove_column :fun_facts, :category, :string
  end
end
