class RemoveTranslatedAttributesFromLegislationQuestions < ActiveRecord::Migration
  def change
    remove_columns :legislation_questions, :title
  end
end
