class AddFeasibilityExplanationToBudgetInvestments < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_investments, :feasibility_explanation, :text
  end
end
