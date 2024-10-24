class AddQuestionAnswerIdToPollAnswers < ActiveRecord::Migration[7.0]
  def change
    change_table :poll_answers do |t|
      t.references :option, index: true, foreign_key: { to_table: :poll_question_answers }

      t.index [:option_id, :author_id], unique: true
    end
  end
end
