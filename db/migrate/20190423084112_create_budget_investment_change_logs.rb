class CreateBudgetInvestmentChangeLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_investment_change_logs do |t|
      t.integer :investment_id
      t.integer :author_id
      t.string :field
      t.string :new_value
      t.string :old_value

      t.timestamps null: false
    end
  end
end
