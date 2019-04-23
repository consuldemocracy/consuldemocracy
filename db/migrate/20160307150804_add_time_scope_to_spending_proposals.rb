class AddTimeScopeToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :time_scope, :string
  end
end
