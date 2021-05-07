class AddAttachmentImagenToDebates < ActiveRecord::Migration[5.2]
  def change
    add_attachment :debates, :imagen
  end
end
