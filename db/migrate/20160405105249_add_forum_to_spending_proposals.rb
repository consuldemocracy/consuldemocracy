class AddForumToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :forum, :boolean, default: false
  end
end
