class AddSlugToBudgetGroups < ActiveRecord::Migration
  def change
    add_column :budget_groups, :slug, :string
  end
end
