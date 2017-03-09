class AddOrganizationNameFieldToBudgetInvestment < ActiveRecord::Migration
  def change
    add_column :budget_investments, :organization_name, :string
  end
end
