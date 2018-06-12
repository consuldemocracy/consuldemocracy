class AddVisibleToValuatorsToBudgetInvestment < ActiveRecord::Migration
  def change
    add_column :budget_investments, :visible_to_valuators, :boolean, default: false
  end
end
