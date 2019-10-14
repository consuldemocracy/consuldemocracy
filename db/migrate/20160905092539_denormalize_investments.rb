class DenormalizeInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :budget_id, :integer, index: true
    add_column :budget_investments, :group_id, :integer, index: true
  end
end
