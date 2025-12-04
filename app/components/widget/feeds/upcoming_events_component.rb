class Widget::Feeds::UpcomingEventsComponent < ApplicationComponent
  attr_reader :events, :limit

  def initialize(event)
    @event = event
  end
end
