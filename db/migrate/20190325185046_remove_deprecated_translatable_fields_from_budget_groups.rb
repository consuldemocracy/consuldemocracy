class RemoveDeprecatedTranslatableFieldsFromBudgetGroups < ActiveRecord::Migration[4.2]
  def change
    remove_column :budget_groups, :name, :string
  end
end
