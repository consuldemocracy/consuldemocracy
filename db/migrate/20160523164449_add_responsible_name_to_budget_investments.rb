class AddResponsibleNameToBudgetInvestments < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :responsible_name, :string
  end
end
