class ChangePriceFieldsInSpendingProposals < ActiveRecord::Migration
  def up
    change_column :spending_proposals, :price, :integer
    change_column :spending_proposals, :price_first_year, :integer
  end

  def down
    change_column :spending_proposals, :price, :float
    change_column :spending_proposals, :price_first_year, :float
  end
end
