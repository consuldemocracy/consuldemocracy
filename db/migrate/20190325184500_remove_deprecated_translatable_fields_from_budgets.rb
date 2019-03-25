class RemoveDeprecatedTranslatableFieldsFromBudgets < ActiveRecord::Migration[4.2]
  def change
    remove_column :budgets, :name, :string
  end
end
