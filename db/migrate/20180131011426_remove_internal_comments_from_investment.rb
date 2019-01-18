class RemoveInternalCommentsFromInvestment < ActiveRecord::Migration
  def change
    remove_column :budget_investments, :internal_comments
  end
end
