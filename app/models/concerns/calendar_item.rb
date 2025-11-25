# frozen_string_literal: true
# app/models/concerns/calendar_item.rb
module CalendarItem
  extend ActiveSupport::Concern

  included do

  end
  def calendar_link_url
    self
  end
  # Interface requirements (for documentation/safety)
  def calendar_title
    respond_to?(:title) ? title : name
  end

  def calendar_start
    # Maps specific fields to a generic one
    respond_to?(:starts_at) ? starts_at : start_date
  end

  def calendar_end
    respond_to?(:ends_at) ? ends_at : end_date
  end

  def calendar_class
    # 1. Base class for all items (good for global styling)
    classes = ["event-bar"]

    # 2. Add a specific class based on the Model Name
    # Event -> "type-event"
    # Budget -> "type-budget"
    # Legislation::Process -> "type-process"
    classes << "type-#{self.class.name.demodulize.downcase}"

    classes.join(" ")
  end
end

