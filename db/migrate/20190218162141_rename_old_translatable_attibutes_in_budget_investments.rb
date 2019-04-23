class RenameOldTranslatableAttibutesInBudgetInvestments < ActiveRecord::Migration
  def change
    rename_column :budget_investments, :title, :deprecated_title
    rename_column :budget_investments, :description, :deprecated_description
  end
end
