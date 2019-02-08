class AddSubAreaToBudgetInvestment < ActiveRecord::Migration
  def up
    add_reference :budget_investments, :sub_area, index: true
  end

  def down
    remove_reference :budget_investments, :sub_area
  end
end
