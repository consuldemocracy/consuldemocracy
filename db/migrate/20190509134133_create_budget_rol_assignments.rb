class CreateBudgetRolAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :budget_rol_assignments do |t|
      t.references :budget, foreign_key: true
      t.references :user, foreign_key: true
      t.string :rol

      t.timestamps
    end
  end
end
