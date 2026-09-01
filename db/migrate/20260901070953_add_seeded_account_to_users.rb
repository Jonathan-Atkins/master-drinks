class AddSeededAccountToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users,
               :seeded_account,
               :boolean,
               default: false,
               null: false

    add_index :users, :seeded_account
  end
end
