class AddReportingFieldsToSpendingProposal < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :price, :float
    add_column :spending_proposals, :legal, :boolean, default: nil
    add_column :spending_proposals, :feasible, :boolean, default: nil
    add_column :spending_proposals, :explanation, :text
  end
end
