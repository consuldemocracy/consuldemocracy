class AddHiddenAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hidden_at, :datetime
    add_index :users, :hidden_at
  end
end
