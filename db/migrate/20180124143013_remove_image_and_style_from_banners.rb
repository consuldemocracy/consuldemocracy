class RemoveImageAndStyleFromBanners < ActiveRecord::Migration[4.2]
  def change
    remove_column :banners, :image
    remove_column :banners, :style
  end
end
