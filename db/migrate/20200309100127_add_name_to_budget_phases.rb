class AddNameToBudgetPhases < ActiveRecord::Migration[5.0]
  def change
    change_table :budget_phase_translations do |t|
      t.string :name
    end
  end
end
