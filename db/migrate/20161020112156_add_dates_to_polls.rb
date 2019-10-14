class AddDatesToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :starts_at, :datetime
    add_column :polls, :ends_at, :datetime
  end
end
