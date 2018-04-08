class AddSlugsToBudgetHeadingGroup < ActiveRecord::Migration
  def change
    add_column :budgets, :slug, :string
    add_column :budget_groups, :slug, :string
    add_column :budget_headings, :slug, :string
  end
end
