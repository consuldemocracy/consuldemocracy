class AddSpendingProposalsIndexes < ActiveRecord::Migration
  def change
    add_index :spending_proposals, :author_id
  end
end
