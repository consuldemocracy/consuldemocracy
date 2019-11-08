class RemovePollQuestionValidAnswers < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_questions, :valid_answers, :string
  end
end
