class RemoveTranslatedAttributesFromLegislationQuestionOptions < ActiveRecord::Migration
  def change
    remove_columns :legislation_question_options, :value
  end
end
