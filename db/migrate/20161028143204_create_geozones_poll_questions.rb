class CreateGeozonesPollQuestions < ActiveRecord::Migration
  def change
    create_table :geozones_poll_questions do |t|
      t.references :geozone, index: true, foreign_key: true
      t.integer :question_id, index: true
    end

    add_foreign_key :geozones_poll_questions, :poll_questions, column: :question_id
  end
end
