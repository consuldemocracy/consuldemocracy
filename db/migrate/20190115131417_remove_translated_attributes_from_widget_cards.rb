class RemoveTranslatedAttributesFromWidgetCards < ActiveRecord::Migration
  def change
    remove_columns :widget_cards, :label, :title, :description, :link_text
  end
end
