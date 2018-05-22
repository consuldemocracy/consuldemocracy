class CreateWidgetCards < ActiveRecord::Migration
  def change
    create_table :widget_cards do |t|
      t.string :title
      t.text :description
      t.string :link_text
      t.string :link_url
      t.string :button_text
      t.string :button_url
      t.boolean :header, default: false
      t.string :alignment
      t.timestamps null: false
    end
  end
end
