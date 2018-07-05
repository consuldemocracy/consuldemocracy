class AddBackgroundOptionToWidgetCards < ActiveRecord::Migration
  def change
    add_column :widget_cards, :is_background_image, :boolean
  end
end
