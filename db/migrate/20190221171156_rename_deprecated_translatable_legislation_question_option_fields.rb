class RenameDeprecatedTranslatableLegislationQuestionOptionFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :legislation_question_options, :value, :deprecated_value
  end
end
