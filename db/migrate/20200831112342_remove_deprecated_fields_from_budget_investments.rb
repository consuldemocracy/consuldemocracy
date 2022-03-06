class RemoveDeprecatedFieldsFromBudgetInvestments < ActiveRecord::Migration[5.1]
  def change
    remove_column :budget_investments, :deprecated_title, :string
    remove_column :budget_investments, :deprecated_description, :text
  end
end
