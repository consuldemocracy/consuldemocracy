class AddPartFundToBudgets < ActiveRecord::Migration[6.1]
  def change
    add_column :budgets, :part_fund, :boolean
  end
end
