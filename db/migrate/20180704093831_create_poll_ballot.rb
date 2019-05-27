class CreatePollBallot < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_ballots do |t|
      t.integer :ballot_sheet_id
      t.text :data
      t.integer :external_id
      t.timestamps null: false
    end
  end
end
