class Admin::Events::EditComponent < ApplicationComponent
  include Header

  attr_reader :event

  def initialize(event)
    @event = event
  end

  private

    def title
      t("events.edit.title", default: "Manage Event")
    end
end
