class AddHiddenAtToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :hidden_at, :datetime
  end
end
