class CreateBudgetAdministrators < ActiveRecord::Migration[5.0]
  def change
    create_table :budget_administrators do |t|
      t.references :budget, foreign_key: true
      t.references :administrator, foreign_key: true

      t.timestamps
    end
  end
end
