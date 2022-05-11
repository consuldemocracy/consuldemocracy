class AddQuestionsToBudgets < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_questions do |t|
      t.references :budget
      t.boolean :enabled, default: true
    end
  end
end
