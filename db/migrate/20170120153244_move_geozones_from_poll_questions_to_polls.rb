class MoveGeozonesFromPollQuestionsToPolls < ActiveRecord::Migration[4.2]
  def up
    drop_table :geozones_poll_questions

    create_table :geozones_polls do |t|
      t.references :geozone, index: true, foreign_key: true
      t.references :poll, index: true, foreign_key: true
    end
  end

  def down
    drop_table :geozones_polls
    fail ActiveRecord::IrreversibleMigration
  end
end
