class AddHelpLinkToBudgets < ActiveRecord::Migration[5.0]
  def change
    add_column :budgets, :help_link, :string
    add_column :budgets, :budget_milestone_tags, :string
    add_column :budgets, :budget_valuation_tags, :string
  end
end
