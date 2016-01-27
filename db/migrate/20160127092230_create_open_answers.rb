class CreateOpenAnswers < ActiveRecord::Migration
  def change
    create_table :open_answers do |t|
      t.text :text
      t.integer :question_code
      t.belongs_to :survey_answer, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
