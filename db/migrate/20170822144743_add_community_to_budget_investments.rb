class AddCommunityToBudgetInvestments < ActiveRecord::Migration[4.2]
  def change
    add_reference :budget_investments, :community, index: true, foreign_key: true
  end
end
