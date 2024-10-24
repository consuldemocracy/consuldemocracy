class RemoveValuatingFromBudgets < ActiveRecord::Migration[4.2]
  def change
    remove_column :budgets, :valuating, :bool
  end
end
