class AddTrigramIndexToProposals < ActiveRecord::Migration
  def up
    add_index :proposals, :description
  end

  def down
    remove_index :proposals, :description
  end
end
