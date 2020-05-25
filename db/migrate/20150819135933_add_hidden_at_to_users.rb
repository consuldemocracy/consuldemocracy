class AddHiddenAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :hidden_at, :datetime
    add_index :users, :hidden_at
  end
end
