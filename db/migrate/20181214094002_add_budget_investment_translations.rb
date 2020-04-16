class AddBudgetInvestmentTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_investment_translations do |t|
      t.integer :budget_investment_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :description

      t.index :budget_investment_id
      t.index :locale
    end
  end
end
