class UseActsAsTaggableInBudgets < ActiveRecord::Migration[5.0]
  def change
    remove_column :budgets, :budget_milestone_tags, :string
    remove_column :budgets, :budget_valuation_tags, :string

    add_column :tags, :budgets_count, :integer, default: 0
    add_index :tags, :budgets_count
  end
end
