class AddLocationToBudgetInvestments < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :location, :string
  end
end
