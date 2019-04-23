class CreateBudgetValuatorAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_valuator_assignments, index: false do |t|
      t.belongs_to :valuator
      t.integer :investment_id, index: true
      t.timestamps null: false
    end
  end
end
