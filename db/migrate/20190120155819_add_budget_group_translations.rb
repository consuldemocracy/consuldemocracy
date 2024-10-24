class AddBudgetGroupTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_group_translations do |t|
      t.integer :budget_group_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :name

      t.index :budget_group_id
      t.index :locale
    end
  end
end
