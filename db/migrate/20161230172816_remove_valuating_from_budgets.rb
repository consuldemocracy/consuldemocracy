class RemoveValuatingFromBudgets < ActiveRecord::Migration
  def change
    remove_column :budgets, :valuating, :bool
  end
end
