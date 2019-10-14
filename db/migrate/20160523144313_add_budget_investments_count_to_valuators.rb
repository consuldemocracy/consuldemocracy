class AddBudgetInvestmentsCountToValuators < ActiveRecord::Migration
  def change
    add_column :valuators, :budget_investments_count, :integer, default: 0
  end
end
