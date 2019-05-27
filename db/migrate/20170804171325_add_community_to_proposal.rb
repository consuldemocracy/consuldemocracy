class AddCommunityToProposal < ActiveRecord::Migration[4.2]
  def change
    add_reference :proposals, :community, index: true, foreign_key: true
  end
end
