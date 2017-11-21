class RemovePollQuestionValidAnswers < ActiveRecord::Migration
  def change
    remove_column :poll_questions, :valid_answers
  end
end
