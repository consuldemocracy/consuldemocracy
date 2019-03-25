class RemoveDeprecatedTranslatableFieldsFromBudgetGroups < ActiveRecord::Migration
  def change
    remove_column :budget_groups, :name, :string
  end
end
