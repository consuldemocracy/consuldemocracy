# This migration comes from consul_assemblies (originally 20180119091741)
class AddConclusionToProposals < ActiveRecord::Migration
  def change
    add_column :consul_assemblies_proposals, :conclusion, :string
  end
end
