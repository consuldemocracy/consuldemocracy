class CreateBudgetTrackers < ActiveRecord::Migration[5.0]
  def change
    create_table :budget_trackers do |t|
      t.references :budget, foreign_key: true
      t.references :tracker, foreign_key: true

      t.timestamps
    end
  end
end
