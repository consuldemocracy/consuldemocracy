class Widget::Card < ApplicationRecord
  include Imageable
  belongs_to :page, class_name: "SiteCustomization::Page", foreign_key: "site_customization_page_id"

  # table_name must be set before calls to 'translates'
  self.table_name = "widget_cards"

  translates :label,       touch: true
  translates :title,       touch: true
  translates :description, touch: true
  translates :link_text,   touch: true
  include Globalizable

  def self.header
    where(header: true)
  end

  def self.body
    where(header: false, site_customization_page_id: nil).order(:created_at)
  end

  #add widget cards to custom pages
  def self.page(page_id)
    where(site_customization_page_id: page_id)
  end

end
