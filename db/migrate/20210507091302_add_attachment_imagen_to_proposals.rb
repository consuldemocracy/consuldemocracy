class AddAttachmentImagenToProposals < ActiveRecord::Migration[5.2]
  def change
    add_attachment :proposals, :imagen
  end
end
