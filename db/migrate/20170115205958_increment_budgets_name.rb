class IncrementBudgetsName < ActiveRecord::Migration
  def change
    change_column :budgets, :name, :string, limit: 40 #GET-59
  end
end
