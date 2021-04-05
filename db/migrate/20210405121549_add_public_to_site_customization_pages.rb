class AddPublicToSiteCustomizationPages < ActiveRecord::Migration[5.2]
  def change
    add_column :site_customization_pages, :public, :boolean
  end
end
