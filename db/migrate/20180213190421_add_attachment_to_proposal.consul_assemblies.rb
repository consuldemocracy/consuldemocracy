# This migration comes from consul_assemblies (originally 20180213190241)
class AddAttachmentToProposal < ActiveRecord::Migration
  def change
  	add_column :consul_assemblies_proposals, :attachment, :string
  end
end
