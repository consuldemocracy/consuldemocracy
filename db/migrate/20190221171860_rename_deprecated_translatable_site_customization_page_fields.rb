class RenameDeprecatedTranslatableSiteCustomizationPageFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :site_customization_pages, :title, :deprecated_title
    rename_column :site_customization_pages, :subtitle, :deprecated_subtitle
    rename_column :site_customization_pages, :content, :deprecated_content
  end
end
