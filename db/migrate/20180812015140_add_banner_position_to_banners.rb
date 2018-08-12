class AddBannerPositionToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :banner_position, :string
  end
end
