class RemoveDeprecatedTranslatableFieldsFromLegislationQuestionOptions < ActiveRecord::Migration[4.2]
  def change
    remove_column :legislation_question_options, :value, :string
  end
end
