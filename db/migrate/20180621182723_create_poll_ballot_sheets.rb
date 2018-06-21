class CreatePollBallotSheets < ActiveRecord::Migration
  def change
    create_table :poll_ballot_sheets do |t|
      t.text :data
      t.integer :poll_id, index: true
      t.integer :officer_assignment_id, index: true
      t.timestamps null: false
    end
  end
end
