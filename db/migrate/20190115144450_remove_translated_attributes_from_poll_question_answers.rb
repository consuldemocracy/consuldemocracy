class RemoveTranslatedAttributesFromPollQuestionAnswers < ActiveRecord::Migration
  def change
    remove_columns :poll_question_answers, :title, :description
  end
end
