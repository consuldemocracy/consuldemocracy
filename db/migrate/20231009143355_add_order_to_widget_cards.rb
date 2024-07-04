class AddOrderToWidgetCards < ActiveRecord::Migration[6.1]
  def change
    add_column :widget_cards, :order, :integer, null: false, default: 1
  end
end
