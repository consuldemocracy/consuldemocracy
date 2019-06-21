class AddLocaleToSiteCustomizationPages < ActiveRecord::Migration[4.2]
  def change
    add_column :site_customization_pages, :locale, :string
  end
end
