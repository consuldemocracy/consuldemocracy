class Widget::Card < ApplicationRecord
  include Imageable
  belongs_to :cardable, polymorphic: true

  translates :label,       touch: true
  translates :title,       touch: true
  translates :description, touch: true
  translates :link_text,   touch: true
  include Globalizable

  validates_translation :title, presence: true

  def self.header
    where(header: true)
  end

  def self.body
    where(header: false, cardable_id: nil).order(:created_at)
  end
end
