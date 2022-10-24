class AddDatesToPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :polls, :starts_at, :datetime
    add_column :polls, :ends_at, :datetime
  end
end
