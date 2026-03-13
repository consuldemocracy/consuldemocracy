class Events::ShowComponent < ApplicationComponent
  attr_reader :event

  def initialize(event)
    @event = event
  end
end
