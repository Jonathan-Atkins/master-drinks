class AddNullConstraintToDrinksCategory < ActiveRecord::Migration[8.1]
  def change
    change_column_null :drinks, :category, false
  end
end