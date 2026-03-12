class Admin::Events::NewComponent < ApplicationComponent
  include Header

  attr_reader :event

  def initialize(event)
    @event = event
  end

  private

    def title
      t("events.new.title", default: "Manage Event")
    end
end
