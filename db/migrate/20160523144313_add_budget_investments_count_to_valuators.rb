class AddBudgetInvestmentsCountToValuators < ActiveRecord::Migration[4.2]
  def change
    add_column :valuators, :budget_investments_count, :integer, default: 0
  end
end
