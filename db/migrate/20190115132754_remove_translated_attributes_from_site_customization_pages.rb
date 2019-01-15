class RemoveTranslatedAttributesFromSiteCustomizationPages < ActiveRecord::Migration
  def change
    remove_columns :site_customization_pages, :title, :subtitle, :content
  end
end
