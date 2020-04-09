class DestroySpendingProposalAssociations < ActiveRecord::Migration[4.2]
  def change
    remove_index :tags, :spending_proposals_count
    remove_column :tags, :spending_proposals_count, :integer, default: 0
    remove_column :valuators, :spending_proposals_count, :integer, default: 0
  end
end
