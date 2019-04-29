class AddsVotableCacheFieldToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :cached_votes_total, :integer, default: 0
    add_column :comments, :cached_votes_up, :integer, default: 0
    add_column :comments, :cached_votes_down, :integer, default: 0

    add_index  :comments, :cached_votes_total
    add_index  :comments, :cached_votes_up
    add_index  :comments, :cached_votes_down
  end
end
