class AddHeadingsToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :headings, :text
  end
end
