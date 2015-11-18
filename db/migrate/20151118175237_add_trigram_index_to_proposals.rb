class AddTrigramIndexToProposals < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_proposals_on_description ON proposals USING gist (description gist_trgm_ops);"
  end

  def down
    remove_index :proposals, :description
  end
end
