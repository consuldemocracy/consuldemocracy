class RemoveDeprecatedTranslatableFieldsFromLegislationQuestions < ActiveRecord::Migration
  def change
    remove_column :legislation_questions, :title, :text
  end
end
