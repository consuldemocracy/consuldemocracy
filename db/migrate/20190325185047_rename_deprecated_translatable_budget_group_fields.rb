class RenameDeprecatedTranslatableBudgetGroupFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :budget_groups, :name, :deprecated_name
  end
end
