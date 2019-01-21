class AddHiddenAtToPollQuestionTranslations < ActiveRecord::Migration
  def change
    add_column :poll_question_translations, :hidden_at, :datetime
    add_index :poll_question_translations, :hidden_at
  end
end
