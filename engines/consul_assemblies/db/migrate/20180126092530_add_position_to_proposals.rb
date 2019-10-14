class AddPositionToProposals < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_proposals, :position, :integer
    ConsulAssemblies::Proposal.order(created_at: 'asc').each.with_index(1) do |proposal, index|
      proposal.update_column :position, index
    end
  end
end
