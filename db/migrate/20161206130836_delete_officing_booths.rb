class DeleteOfficingBooths < ActiveRecord::Migration
  def self.up
    drop_table :poll_officing_booths
  end

  def self.down
  end
end
