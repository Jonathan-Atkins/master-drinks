class AddCaseInsensitiveUniqueIndexesToUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, :username if index_exists?(:users, :username)

    add_index :users,
              "LOWER(username)",
              unique: true,
              name: "index_users_on_lower_username"

    add_index :users,
              "LOWER(email)",
              unique: true,
              name: "index_users_on_lower_email"
  end
end
