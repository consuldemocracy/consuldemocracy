class AddAssociationToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :association_name, :string
  end
end
