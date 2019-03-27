class RemoveDeprecatedTranslatableFieldsFromBudgetHeadings < ActiveRecord::Migration
  def change
    remove_column :budget_headings, :name, :string
  end
end
