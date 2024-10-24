class RenamePollQuestionIdToQuestionId < ActiveRecord::Migration[4.2]
  def change
    rename_column :poll_question_answers, :poll_question_id, :question_id
  end
end
