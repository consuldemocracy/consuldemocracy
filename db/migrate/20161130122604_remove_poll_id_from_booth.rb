class RemovePollIdFromBooth < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_booths, :poll_id, :integer
  end
end
