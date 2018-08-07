class AddSettingsToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :background_color, :text
    add_column :banners, :font_color, :text
  end
end
