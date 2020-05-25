class CreateBudgetInvestmentStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_investment_statuses do |t|
      t.string :name
      t.text :description
      t.datetime :hidden_at, index: true

      t.timestamps null: false
    end
  end
end
