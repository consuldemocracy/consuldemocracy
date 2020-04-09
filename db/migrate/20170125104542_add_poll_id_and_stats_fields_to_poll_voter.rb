class AddPollIdAndStatsFieldsToPollVoter < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_voters, :poll_id, :integer, null: false

    remove_column :poll_voters, :booth_assignment_id, :integer, null: false
    add_column :poll_voters, :booth_assignment_id, :integer

    add_column :poll_voters, :age, :integer
    add_column :poll_voters, :gender, :string
    add_column :poll_voters, :geozone_id, :integer
  end
end
