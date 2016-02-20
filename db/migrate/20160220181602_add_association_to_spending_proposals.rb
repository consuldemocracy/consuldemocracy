class AddAssociationToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :association_name, :string
  end
end
