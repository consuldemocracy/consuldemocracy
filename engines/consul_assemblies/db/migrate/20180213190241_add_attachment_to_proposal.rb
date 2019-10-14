class AddAttachmentToProposal < ActiveRecord::Migration
  def change
  	add_column :consul_assemblies_proposals, :attachment, :string
  end
end
