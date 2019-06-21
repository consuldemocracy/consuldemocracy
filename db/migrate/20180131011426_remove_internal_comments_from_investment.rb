class RemoveInternalCommentsFromInvestment < ActiveRecord::Migration[4.2]
  def change
    remove_column :budget_investments, :internal_comments
  end
end
