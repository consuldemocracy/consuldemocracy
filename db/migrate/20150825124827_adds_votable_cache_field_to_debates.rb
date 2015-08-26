class AddsVotableCacheFieldToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :cached_votes_total, :integer, default: 0
    add_column :debates, :cached_votes_up, :integer, default: 0
    add_column :debates, :cached_votes_down, :integer, default: 0

    add_index  :debates, :cached_votes_total
    add_index  :debates, :cached_votes_up
    add_index  :debates, :cached_votes_down
  end
end
