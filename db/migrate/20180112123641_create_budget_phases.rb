class CreateBudgetPhases < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_phases do |t|
      t.references :budget
      t.references :next_phase, index: true
      t.string :kind, null: false, index: true
      t.text :summary
      t.text :description
      t.datetime :starts_at, index: true
      t.datetime :ends_at, index: true
      t.boolean :enabled, default: true
    end
  end
end
