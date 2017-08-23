class RemovePollIdFromBooth < ActiveRecord::Migration
  def change
    remove_column :poll_booths, :poll_id, :integer
  end
end
