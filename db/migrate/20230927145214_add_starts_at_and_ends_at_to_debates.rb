class AddStartsAtAndEndsAtToDebates < ActiveRecord::Migration[6.1]
  def change
    add_column :debates, :starts_at, :datetime
    add_column :debates, :ends_at, :datetime
  end
end
