class DropBudgetRolAssignments < ActiveRecord::Migration[5.0]
  def up
    drop_table :budget_rol_assignments
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
