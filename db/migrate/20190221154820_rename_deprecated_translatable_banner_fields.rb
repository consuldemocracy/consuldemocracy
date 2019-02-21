class RenameDeprecatedTranslatableBannerFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :banners, :title, :deprecated_title
    rename_column :banners, :description, :deprecated_description
  end
end
