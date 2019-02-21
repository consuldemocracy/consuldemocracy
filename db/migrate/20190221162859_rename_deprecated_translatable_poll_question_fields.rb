class RenameDeprecatedTranslatablePollQuestionFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :poll_questions, :title, :deprecated_title
  end
end
