class AddSpendingIdToBudgetInvesment < ActiveRecord::Migration
  def change
    add_column :budget_investments, :original_spending_proposal_id, :integer
  end
end
