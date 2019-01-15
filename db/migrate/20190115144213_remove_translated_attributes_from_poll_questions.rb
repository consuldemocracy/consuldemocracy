class RemoveTranslatedAttributesFromPollQuestions < ActiveRecord::Migration
  def change
    remove_columns :poll_questions, :title
  end
end
