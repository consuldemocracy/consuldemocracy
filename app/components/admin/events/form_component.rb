class Admin::Events::FormComponent < ApplicationComponent
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def submit_button_text
    action = event.persisted? ? "edit" : "new"
    t("events.#{action}.submit_button", default: t("events.submit.default"))
  end
end
