class AddOfficerToPollVoter < ActiveRecord::Migration
  def change
    add_column :poll_voters, :officer_id, :integer
  end
end
