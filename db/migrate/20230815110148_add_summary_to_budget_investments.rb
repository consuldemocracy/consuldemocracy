class AddSummaryToBudgetInvestments < ActiveRecord::Migration[6.0]
  def change
    add_column :budget_investments, :summary, :text
  end
end