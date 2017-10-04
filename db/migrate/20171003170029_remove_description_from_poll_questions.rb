class RemoveDescriptionFromPollQuestions < ActiveRecord::Migration
  def change
    remove_column :poll_questions, :description
  end
end
