class RemoveQuestionFromPollQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_questions, :question, :string
  end
end
