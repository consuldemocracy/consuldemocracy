class RenameDeprecatedTranslatableBudgetHeadingFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :budget_headings, :name, :deprecated_name
  end
end
