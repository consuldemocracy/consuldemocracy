class DjndAddAnswersToBudgetInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_investments, :answers, :text, array: true, default: []
  end
end
