class RemoveImageAndStyleFromBanners < ActiveRecord::Migration
  def change
    remove_column :banners, :image
    remove_column :banners, :style
  end
end
