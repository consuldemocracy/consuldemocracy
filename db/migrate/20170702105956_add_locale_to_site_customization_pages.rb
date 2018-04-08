class AddLocaleToSiteCustomizationPages < ActiveRecord::Migration
  def change
    add_column :site_customization_pages, :locale, :string
  end
end
