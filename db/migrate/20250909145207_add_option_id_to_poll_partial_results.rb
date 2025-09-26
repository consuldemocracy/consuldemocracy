class AddOptionIdToPollPartialResults < ActiveRecord::Migration[7.1]
  def change
    change_table :poll_partial_results do |t|
      t.references :option, index: true, foreign_key: { to_table: :poll_question_answers }

      t.index [:booth_assignment_id, :date, :option_id], unique: true
    end
  end
end
