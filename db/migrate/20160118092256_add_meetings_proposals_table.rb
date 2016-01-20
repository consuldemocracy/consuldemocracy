class AddMeetingsProposalsTable < ActiveRecord::Migration
  def change
    create_table :meetings_proposals do |t|
      t.integer :meeting_id
      t.integer :proposal_id
    end
  end
end
