class AddOfficerAssignmentToVotes < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_voters, :officer_assignment_id, :integer, default: nil
  end
end
