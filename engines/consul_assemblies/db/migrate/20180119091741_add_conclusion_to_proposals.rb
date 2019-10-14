class AddConclusionToProposals < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_proposals, :conclusion, :string
  end
end
