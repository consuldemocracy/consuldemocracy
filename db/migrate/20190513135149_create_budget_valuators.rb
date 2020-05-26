class CreateBudgetValuators < ActiveRecord::Migration[5.0]
  def change
    create_table :budget_valuators do |t|
      t.references :budget, foreign_key: true
      t.references :valuator, foreign_key: true

      t.timestamps
    end
  end
end
