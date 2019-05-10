class AddSiteCustomizationPageToWidgetCards < ActiveRecord::Migration[4.2]
  def change
    add_reference :widget_cards, :site_customization_page, index: true
  end
end
