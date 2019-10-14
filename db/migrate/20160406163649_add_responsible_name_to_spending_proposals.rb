class AddResponsibleNameToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :responsible_name, :string, limit: 60
  end
end
