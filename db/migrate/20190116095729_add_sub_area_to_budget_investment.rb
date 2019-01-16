class AddSubAreaToBudgetInvestment < ActiveRecord::Migration
  def up
    add_column :budget_investments, :sub_area_id, :integer
  end

  def down
    remove_column :budget_investments, :sub_area_id
  end
end
