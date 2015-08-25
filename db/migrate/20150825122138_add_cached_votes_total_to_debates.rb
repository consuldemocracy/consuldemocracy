class AddCachedVotesTotalToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :cached_votes_total, :integer, :default => 0
    add_index  :debates, :cached_votes_total
  end
end
