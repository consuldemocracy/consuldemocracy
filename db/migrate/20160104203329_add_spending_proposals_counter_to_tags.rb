class AddSpendingProposalsCounterToTags < ActiveRecord::Migration
  def change
    add_column :tags, :spending_proposals_count, :integer, default: 0
    add_index :tags, :spending_proposals_count
  end
end
