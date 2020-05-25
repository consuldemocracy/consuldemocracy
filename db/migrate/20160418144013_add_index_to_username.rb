class AddIndexToUsername < ActiveRecord::Migration[4.2]
  def change
    add_index :users, :username
  end
end
