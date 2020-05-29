class AddHiddenAtToDebates < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :hidden_at, :datetime
    add_index :debates, :hidden_at
  end
end
