class AddCachedVotesTotalToComments < ActiveRecord::Migration
  def change
    add_column :comments, :cached_votes_total, :integer, :default => 0
    add_index  :comments, :cached_votes_total
  end
end
