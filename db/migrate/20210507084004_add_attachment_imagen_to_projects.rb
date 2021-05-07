class AddAttachmentImagenToProjects < ActiveRecord::Migration[5.2]
  def change
    add_attachment :projects, :imagen
  end
end
