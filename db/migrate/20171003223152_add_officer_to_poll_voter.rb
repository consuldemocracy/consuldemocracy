class AddOfficerToPollVoter < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_voters, :officer_id, :integer
  end
end
