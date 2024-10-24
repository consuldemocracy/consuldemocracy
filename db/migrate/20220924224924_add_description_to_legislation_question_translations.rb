class AddDescriptionToLegislationQuestionTranslations < ActiveRecord::Migration[6.0]
  def change
    add_column :legislation_question_translations, :description, :text
  end
end
