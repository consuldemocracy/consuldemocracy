class RenameDeprecatedTranslatableBudgetFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :budgets, :name, :deprecated_name
  end
end
