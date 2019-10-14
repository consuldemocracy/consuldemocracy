class AddLocationToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :location, :string
  end
end
