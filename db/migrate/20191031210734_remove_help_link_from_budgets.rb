class RemoveHelpLinkFromBudgets < ActiveRecord::Migration[5.0]
  def change
    remove_column :budgets, :help_link, :string
    remove_column :tags, :budgets_count, :integer, default: 0
  end
end
