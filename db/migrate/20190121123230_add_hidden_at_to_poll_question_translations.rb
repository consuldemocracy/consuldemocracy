class AddHiddenAtToPollQuestionTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_question_translations, :hidden_at, :datetime
    add_index :poll_question_translations, :hidden_at
  end
end
