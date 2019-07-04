class AddColumnsToWidgetCards < ActiveRecord::Migration
  def change
    add_column :widget_cards, :columns, :integer, default: 4
  end
end
