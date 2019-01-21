class AddHiddenAtToLegislationQuestionTranslations < ActiveRecord::Migration
  def change
    add_column :legislation_question_translations, :hidden_at, :datetime
    add_index :legislation_question_translations, :hidden_at
  end
end
