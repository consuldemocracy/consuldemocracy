class CreateBudgetTrackerAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :budget_tracker_assignments, index: false do |t|
      t.references :tracker, foreign_key: true
      t.integer :investment_id, index: true

      t.timestamps null: false
    end
  end
end
