class AddUserToDrinks < ActiveRecord::Migration[8.1]
  def change
    add_reference :drinks, :user, null: false, foreign_key: true
  end
end
