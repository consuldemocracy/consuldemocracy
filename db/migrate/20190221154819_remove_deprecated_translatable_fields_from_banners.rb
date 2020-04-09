class RemoveDeprecatedTranslatableFieldsFromBanners < ActiveRecord::Migration[4.2]
  def change
    remove_column :banners, :title, :string
    remove_column :banners, :description, :string
  end
end
