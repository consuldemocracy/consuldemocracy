class RemoveDeprecatedTranslatableFieldsFromBanners < ActiveRecord::Migration
  def change
    remove_column :banners, :title, :string
    remove_column :banners, :description, :string
  end
end
