class RemoveDeprecatedTranslatableFieldsFromLegislationQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :legislation_questions, :title, :text
  end
end
