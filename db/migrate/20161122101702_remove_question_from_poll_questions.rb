class RemoveQuestionFromPollQuestions < ActiveRecord::Migration
  def change
    remove_column :poll_questions, :question
  end
end
