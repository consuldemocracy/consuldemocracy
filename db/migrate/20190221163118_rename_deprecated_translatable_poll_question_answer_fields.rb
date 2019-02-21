class RenameDeprecatedTranslatablePollQuestionAnswerFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :poll_question_answers, :title, :deprecated_title
    rename_column :poll_question_answers, :description, :deprecated_description
  end
end
