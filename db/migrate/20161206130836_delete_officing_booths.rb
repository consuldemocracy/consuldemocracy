class DeleteOfficingBooths < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :poll_officing_booths
  end

  def self.down
  end
end
