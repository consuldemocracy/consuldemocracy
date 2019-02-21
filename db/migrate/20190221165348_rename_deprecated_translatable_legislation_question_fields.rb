class RenameDeprecatedTranslatableLegislationQuestionFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :legislation_questions, :title, :deprecated_title
  end
end
