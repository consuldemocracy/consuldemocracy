class Widget::Card < ActiveRecord::Base
  include Imageable

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
    where(header: false).order(:created_at)
  end
end
