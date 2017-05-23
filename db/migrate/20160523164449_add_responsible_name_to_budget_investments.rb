class AddResponsibleNameToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :responsible_name, :string
  end
end
