class AddBudgetTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_translations do |t|
      t.integer :budget_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :name

      t.index :budget_id
      t.index :locale
    end
  end
end
