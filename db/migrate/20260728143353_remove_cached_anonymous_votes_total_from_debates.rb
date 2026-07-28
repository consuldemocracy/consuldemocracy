class RemoveCachedAnonymousVotesTotalFromDebates < ActiveRecord::Migration[8.0]
  def change
    remove_column :debates, :cached_anonymous_votes_total, :integer, default: 0
  end
end
