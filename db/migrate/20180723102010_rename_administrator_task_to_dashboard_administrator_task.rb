class RenameAdministratorTaskToDashboardAdministratorTask < ActiveRecord::Migration[4.2]
  def change
    rename_index :administrator_tasks, "index_administrator_tasks_on_source_type_and_source_id", "index_dashboard_administrator_tasks_on_source"
    rename_table :administrator_tasks, :dashboard_administrator_tasks
  end
end
