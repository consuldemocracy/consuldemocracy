class AddCachedVotesUpToBenches < ActiveRecord::Migration
  def change
    add_column :benches, :cached_votes_up, :integer, default: 0
    add_index  :benches, :cached_votes_up
  end
end
