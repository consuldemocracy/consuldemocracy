class AddTsvectorToSpendingProposals < ActiveRecord::Migration
  def up
    add_column :spending_proposals, :tsv, :tsvector
    add_index :spending_proposals, :tsv, using: "gin"
  end

  def down
    remove_index :spending_proposals, :tsv
    remove_column :spending_proposals, :tsv
  end

end
