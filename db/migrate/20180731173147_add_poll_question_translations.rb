class AddPollQuestionTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_question_translations do |t|
      t.integer :poll_question_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title

      t.index :locale
      t.index :poll_question_id
    end
  end
end
