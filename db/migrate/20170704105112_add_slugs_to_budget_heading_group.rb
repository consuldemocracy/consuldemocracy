class AddSlugsToBudgetHeadingGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :budgets, :slug, :string
    add_column :budget_groups, :slug, :string
    add_column :budget_headings, :slug, :string
  end
end
