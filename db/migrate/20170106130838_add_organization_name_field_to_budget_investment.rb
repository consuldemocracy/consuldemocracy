class AddOrganizationNameFieldToBudgetInvestment < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :organization_name, :string
  end
end
