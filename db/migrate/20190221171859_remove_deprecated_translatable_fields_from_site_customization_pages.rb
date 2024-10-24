class RemoveDeprecatedTranslatableFieldsFromSiteCustomizationPages < ActiveRecord::Migration[4.2]
  def change
    remove_column :site_customization_pages, :title, :string
    remove_column :site_customization_pages, :subtitle, :string
    remove_column :site_customization_pages, :content, :text
  end
end
