# frozen_string_literal: true
module CalendarItem
  extend ActiveSupport::Concern

  def calendar_link_url
    self
  end

  def calendar_title
    respond_to?(:title) ? title : name
  end

  def calendar_start
    respond_to?(:starts_at) ? starts_at : start_date
  end

  def calendar_end
    respond_to?(:ends_at) ? ends_at : end_date
  end

  def calendar_class
    classes = ["event-bar"]

    # Add a specific class based on the Model Name
    # Event -> "type-event"
    # Budget -> "type-budget"
    # Legislation::Process -> "type-process"
    classes << "type-#{self.class.name.demodulize.downcase}"

    classes.join(" ")
  end
end
