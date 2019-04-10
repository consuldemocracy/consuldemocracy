class AddCommentsCountToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :comments_count, :integer
  end
end
