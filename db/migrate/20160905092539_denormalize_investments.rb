class DenormalizeInvestments < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :budget_id, :integer
    add_column :budget_investments, :group_id, :integer
  end
end
