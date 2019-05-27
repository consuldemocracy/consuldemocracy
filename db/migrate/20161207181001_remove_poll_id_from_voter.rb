class RemovePollIdFromVoter < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_voters, :poll_id, :integer
  end
end
