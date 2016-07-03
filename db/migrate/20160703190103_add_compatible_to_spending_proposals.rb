class AddCompatibleToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :compatible, :boolean, default: true
  end
end
