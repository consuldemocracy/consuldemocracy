class AddTimeScopeToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :time_scope, :string
  end
end
