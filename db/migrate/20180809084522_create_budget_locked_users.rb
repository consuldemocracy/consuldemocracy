class CreateBudgetLockedUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_locked_users do |t|
      t.string :document_number
      t.string :document_type
      t.references :budget, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :budget_locked_users, :document_number
  end
end
