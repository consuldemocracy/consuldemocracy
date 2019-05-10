class AddVisibleToValuatorsToBudgetInvestment < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :visible_to_valuators, :boolean, default: false
  end
end
