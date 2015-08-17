class AddHiddenAtToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :hidden_at, :datetime
    add_index :debates, :hidden_at
  end
end
