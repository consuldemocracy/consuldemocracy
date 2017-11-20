class RenamesVotingSelectingInProbes < ActiveRecord::Migration
  def change
    rename_column :probes, :voting_allowed, :selecting_allowed
  end
end
