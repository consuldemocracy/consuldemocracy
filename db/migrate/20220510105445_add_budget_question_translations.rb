class AddBudgetQuestionTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_question_translations do |t|
      t.integer :budget_question_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.text :text
    end
  end
end
