class Widget::Card < ActiveRecord::Base
  include Imageable

  self.table_name = "widget_cards"

  def self.header
    where(header: true)
  end

  def self.body
    where(header: false).order(:created_at)
  end
end