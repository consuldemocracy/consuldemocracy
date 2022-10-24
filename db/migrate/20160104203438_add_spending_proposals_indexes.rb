class AddSpendingProposalsIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :spending_proposals, :author_id
  end
end
