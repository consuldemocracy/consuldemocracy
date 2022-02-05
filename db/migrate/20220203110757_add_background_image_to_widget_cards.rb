class AddBackgroundImageToWidgetCards < ActiveRecord::Migration[5.2]
  def change
    add_column :widget_cards, :background_image, :boolean, default: false
  end
end
