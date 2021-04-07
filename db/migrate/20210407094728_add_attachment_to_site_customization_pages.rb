class AddAttachmentToSiteCustomizationPages < ActiveRecord::Migration[5.2]
  def change
    add_attachment :site_customization_pages, :imagen
  end
end
