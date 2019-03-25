class RenameDeprecatedTranslatableBudgetPhaseFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :budget_phases, :summary, :deprecated_summary
    rename_column :budget_phases, :description, :deprecated_description
  end
end
