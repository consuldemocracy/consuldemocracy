class AddSlugToBudgetHeadings < ActiveRecord::Migration
  def change
    add_column :budget_headings, :slug, :string
  end
end
