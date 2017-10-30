class AddProposalTypeToLegislationProposals < ActiveRecord::Migration
  def change
    add_column :legislation_proposals, :proposal_type, :string
  end
end
