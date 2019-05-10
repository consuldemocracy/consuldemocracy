class AddColumnsToWidgetCards < ActiveRecord::Migration[4.2]
  def change
    add_column :widget_cards, :columns, :integer, default: 4
  end
end
