class AddTrigramIndexToProposals < ActiveRecord::Migration
  def up
    add_index :proposals, :description, using: :gist
  end

  def down
    remove_index :proposals, :description
  end
end
