class RemoveDeprecatedTranslatableFieldsFromPollQuestionAnswers < ActiveRecord::Migration
  def change
    remove_column :poll_question_answers, :title, :string
    remove_column :poll_question_answers, :description, :text
  end
end
