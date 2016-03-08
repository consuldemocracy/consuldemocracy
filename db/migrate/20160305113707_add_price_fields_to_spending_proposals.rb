class AddPriceFieldsToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :price_first_year, :float
  end
end
