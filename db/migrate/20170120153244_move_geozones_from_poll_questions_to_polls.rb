class MoveGeozonesFromPollQuestionsToPolls < ActiveRecord::Migration
  def change
    drop_table :geozones_poll_questions

    create_table :geozones_polls do |t|
      t.references :geozone, index: true, foreign_key: true
      t.references :poll, index: true, foreign_key: true
    end
  end
end
