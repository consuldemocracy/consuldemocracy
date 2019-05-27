class AddSettingsToBanners < ActiveRecord::Migration[4.2]
  def change
    add_column :banners, :background_color, :text
    add_column :banners, :font_color, :text
  end
end
