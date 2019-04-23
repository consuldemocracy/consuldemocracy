class AddHiddenAtToBudgetInvestmentTranslations < ActiveRecord::Migration
  def change
    add_column :budget_investment_translations, :hidden_at, :datetime
    add_index :budget_investment_translations, :hidden_at
  end
end
