class RemoveDeprecatedTranslatableFieldsFromWidgetCards < ActiveRecord::Migration[4.2]
  def change
    remove_column :widget_cards, :label, :string
    remove_column :widget_cards, :title, :string
    remove_column :widget_cards, :description, :text
    remove_column :widget_cards, :link_text, :string
  end
end
