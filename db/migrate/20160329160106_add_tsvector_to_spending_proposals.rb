class AddTsvectorToSpendingProposals < ActiveRecord::Migration

  def change
    add_column :spending_proposals, :tsv, :tsvector
    add_index :spending_proposals, :tsv, using: "gin"
  end

end