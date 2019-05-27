class AddPriceFieldsToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :price_first_year, :float
  end
end
