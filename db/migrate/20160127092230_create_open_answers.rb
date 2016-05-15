class CreateOpenAnswers < ActiveRecord::Migration
  def change
    create_table :open_answers do |t|
      t.text :text
      t.integer :question_code
      t.integer :user_id, index: true
      t.integer :survey_code

      t.timestamps null: false
    end
  end
end
