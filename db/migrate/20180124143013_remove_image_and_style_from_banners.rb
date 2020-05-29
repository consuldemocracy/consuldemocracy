class RemoveImageAndStyleFromBanners < ActiveRecord::Migration[4.2]
  def change
    remove_column :banners, :image, :string
    remove_column :banners, :style, :string
  end
end
