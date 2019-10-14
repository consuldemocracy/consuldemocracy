class AddCustomFieldsToSpendingProposals < ActiveRecord::Migration
  def change

    add_column :spending_proposals, :spending_type, :string, null: nil
    add_column :spending_proposals, :phase, :string, default: 'pre_bidding'

  end
end
