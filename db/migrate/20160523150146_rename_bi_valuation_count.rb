class RenameBiValuationCount < ActiveRecord::Migration
  def change
    rename_column :budget_investments, :valuation_assignments_count, :valuator_assignments_count
  end
end
