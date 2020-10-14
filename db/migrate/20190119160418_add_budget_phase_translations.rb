class AddBudgetPhaseTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_phase_translations do |t|
      t.integer :budget_phase_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.text :description
      t.text :summary

      t.index :budget_phase_id
      t.index :locale
    end
  end
end
