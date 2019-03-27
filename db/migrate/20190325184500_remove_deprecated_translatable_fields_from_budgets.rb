class RemoveDeprecatedTranslatableFieldsFromBudgets < ActiveRecord::Migration
  def change
    remove_column :budgets, :name, :string
  end
end
