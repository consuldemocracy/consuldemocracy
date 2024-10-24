class AddTsvectorToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :tsv, :tsvector
    add_index :spending_proposals, :tsv, using: "gin"
  end
end
