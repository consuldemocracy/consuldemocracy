class RenameBoothIdToBoothAssignmentId < ActiveRecord::Migration
  def change
    remove_column :poll_voters, :booth_id,            :integer

    add_column    :poll_voters, :booth_assignment_id, :integer,  null: false
    add_column    :poll_voters, :poll_id,             :integer,  null: false
    add_column    :poll_voters, :created_at,          :datetime, null: false
    add_column    :poll_voters, :updated_at,          :datetime, null: false
  end
end
