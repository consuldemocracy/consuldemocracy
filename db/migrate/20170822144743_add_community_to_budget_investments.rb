class AddCommunityToBudgetInvestments < ActiveRecord::Migration
  def change
    add_reference :budget_investments, :community, index: true, foreign_key: true
  end
end
