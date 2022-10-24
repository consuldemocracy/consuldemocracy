class RemoveDeprecatedTranslatableFieldsFromBudgetHeadings < ActiveRecord::Migration[4.2]
  def change
    remove_column :budget_headings, :name, :string
  end
end
