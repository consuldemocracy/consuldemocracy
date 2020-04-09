class RemoveDescriptionFromPollQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_questions, :description, :text
  end
end
