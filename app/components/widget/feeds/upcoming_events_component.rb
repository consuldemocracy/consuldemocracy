class Widget::Feeds::UpcomingEventsComponent < ApplicationComponent
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def title
    @event.respond_to?(:calendar_title) ? @event.calendar_title : @event.name
  end

  def url
    @event.respond_to?(:calendar_link_url) ? @event.calendar_link_url : @event
  end

  def date_object
    @event.respond_to?(:calendar_start) ? @event.calendar_start : @event.starts_at
  end
end
