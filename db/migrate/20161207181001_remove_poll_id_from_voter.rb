class RemovePollIdFromVoter < ActiveRecord::Migration
  def change
    remove_column :poll_voters, :poll_id, :integer
  end
end
