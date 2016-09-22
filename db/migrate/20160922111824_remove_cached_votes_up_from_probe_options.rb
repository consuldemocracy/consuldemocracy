class RemoveCachedVotesUpFromProbeOptions < ActiveRecord::Migration
  def change
    remove_column :probe_options, :cached_votes_up, :integer, default: 0
  end
end
