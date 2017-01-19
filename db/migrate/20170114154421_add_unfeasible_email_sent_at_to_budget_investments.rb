class AddUnfeasibleEmailSentAtToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :unfeasible_email_sent_at, :datetime
  end
end
