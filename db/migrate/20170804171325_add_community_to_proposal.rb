class AddCommunityToProposal < ActiveRecord::Migration
  def change
    add_reference :proposals, :community, index: true, foreign_key: true
  end
end
