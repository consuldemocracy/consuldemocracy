class AddCachedAnonymousVotesTotalToDebate < ActiveRecord::Migration
  def change
    add_column :debates, :cached_anonymous_votes_total, :integer, default: 0
  end
end
