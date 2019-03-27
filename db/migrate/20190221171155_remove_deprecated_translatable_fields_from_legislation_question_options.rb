class RemoveDeprecatedTranslatableFieldsFromLegislationQuestionOptions < ActiveRecord::Migration
  def change
    remove_column :legislation_question_options, :value, :string
  end
end
