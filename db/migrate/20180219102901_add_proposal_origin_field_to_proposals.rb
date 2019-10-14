class AddProposalOriginFieldToProposals < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_proposals, :proposal_origin, :string, default: 'user'
  end
end
