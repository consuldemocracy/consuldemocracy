class RemoveDeprecatedTranslatableFieldsFromBudgetPhases < ActiveRecord::Migration[4.2]
  def change
    remove_column :budget_phases, :summary, :text
    remove_column :budget_phases, :description, :text
  end
end
