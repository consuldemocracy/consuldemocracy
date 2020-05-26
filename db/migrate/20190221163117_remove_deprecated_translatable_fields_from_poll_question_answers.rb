class RemoveDeprecatedTranslatableFieldsFromPollQuestionAnswers < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_question_answers, :title, :string
    remove_column :poll_question_answers, :description, :text
  end
end
