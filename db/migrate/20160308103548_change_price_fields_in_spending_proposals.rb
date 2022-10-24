class ChangePriceFieldsInSpendingProposals < ActiveRecord::Migration[4.2]
  def up
    change_column :spending_proposals, :price, :integer
    change_column :spending_proposals, :price_first_year, :integer
  end

  def down
    change_column :spending_proposals, :price, :float
    change_column :spending_proposals, :price_first_year, :float
  end
end
