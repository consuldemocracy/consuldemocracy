class RenameDeprecatedTranslatableWidgetCardFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :widget_cards, :label, :deprecated_label
    rename_column :widget_cards, :title, :deprecated_title
    rename_column :widget_cards, :description, :deprecated_description
    rename_column :widget_cards, :link_text, :deprecated_link_text
  end
end
