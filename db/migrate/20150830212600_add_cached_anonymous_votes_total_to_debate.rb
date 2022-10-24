class AddCachedAnonymousVotesTotalToDebate < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :cached_anonymous_votes_total, :integer, default: 0
  end
end
