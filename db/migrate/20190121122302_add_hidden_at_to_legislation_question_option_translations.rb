class AddHiddenAtToLegislationQuestionOptionTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_question_option_translations, :hidden_at, :datetime
    add_index :legislation_question_option_translations, :hidden_at
  end
end
