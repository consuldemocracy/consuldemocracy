class AddPollQuestionAnswerTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_question_answer_translations do |t|
      t.integer :poll_question_answer_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :description

      t.index :locale
      t.index :poll_question_answer_id, name: "index_85270fa85f62081a3a227186b4c95fe4f7fa94b9"
    end
  end
end
