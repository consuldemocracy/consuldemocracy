class AddHiddenAtToBudgetInvestmentTranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investment_translations, :hidden_at, :datetime
    add_index :budget_investment_translations, :hidden_at
  end
end
